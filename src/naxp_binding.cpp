// naxp: encoded ASCII expressions for R
//
// This file is licensed to you under the Apache Licence 2.0.
//
// Copyright (c) Tim Gordon

#include <cmath>
#include <cstdint>
#include <cstdio>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

#include <cpp11.hpp>
#include <Rinternals.h>

#include "naxp.h"
#include "naxp_cpp.h"

namespace
{
	using naxp_pointer = cpp11::external_pointer<logmu::naxp>;

	// How R holds a naxp's encoded values, decided by its largest one.
	enum class value_storage : int
	{
		integer = 0,
		double_precision = 1,
		too_large = 2,
	};

	// The largest encoded value R holds as an integer, and as an exact double.
	constexpr std::uint64_t max_integer_value = 2147483647u;
	constexpr std::uint64_t max_double_value = std::uint64_t{1} << 53;

	// The naxp an external pointer from cpp_naxp_parse() holds.
	const logmu::naxp& naxp_of(SEXP pointer)
	{
		const logmu::naxp* expression = naxp_pointer(pointer).get();
		if (expression == nullptr)
		{
			cpp11::stop("The naxp is no longer available. Parse its pattern again with naxp_parse().");
		}
		return *expression;
	}

	value_storage storage_of(const logmu::naxp& expression)
	{
		const std::uint64_t max_encoded_value = expression.max_encoded_value();
		if (max_encoded_value <= max_integer_value)
		{
			return value_storage::integer;
		}
		if (max_encoded_value <= max_double_value)
		{
			return value_storage::double_precision;
		}
		return value_storage::too_large;
	}

	// The bytes of an R string exactly as stored, untranslated, so that non-ASCII text in any
	// marked encoding stays non-ASCII and is never accepted.
	std::string_view text_of(SEXP element)
	{
		return std::string_view(CHAR(element), static_cast<std::size_t>(LENGTH(element)));
	}

	SEXP make_string(const char* text, std::size_t length)
	{
		return cpp11::safe[Rf_mkCharLenCE](text, static_cast<int>(length), CE_UTF8);
	}

	const char* relationship_name(logmu::set_relationship relationship)
	{
		switch (relationship)
		{
		case logmu::set_relationship::equal:
			return "equal";
		case logmu::set_relationship::subset_of:
			return "subset_of";
		case logmu::set_relationship::superset_of:
			return "superset_of";
		case logmu::set_relationship::incomparable:
			break;
		}
		return "incomparable";
	}

	std::string format_value(double value)
	{
		char buffer[64];
		std::snprintf(buffer, sizeof buffer, "%.17g", value);
		return buffer;
	}

	// Checks one value from R against a naxp, returning it as an encoded value. A missing
	// value is returned as zero where allowed, which is what it decodes the same as.
	std::uint64_t checked_value(
		double value,
		bool is_missing,
		R_xlen_t index,
		std::uint64_t max_encoded_value,
		bool allow_missing,
		const std::string& argument)
	{
		const std::string position = argument + "[" + std::to_string(index + 1) + "]";
		if (is_missing)
		{
			if (allow_missing)
			{
				return 0;
			}
			cpp11::stop(
				"%s is NA, but encoded values are never NA. Use 0 for text that is not valid.",
				position.c_str());
		}
		if (!std::isfinite(value) || value != std::floor(value))
		{
			cpp11::stop("%s is %s, which is not a whole number.", position.c_str(), format_value(value).c_str());
		}
		if (value < 0)
		{
			cpp11::stop("%s is %s, which is negative.", position.c_str(), format_value(value).c_str());
		}
		if (value > static_cast<double>(max_encoded_value))
		{
			cpp11::stop(
				"%s is %s, above the naxp's maximum encoded value of %s.",
				position.c_str(),
				format_value(value).c_str(),
				std::to_string(max_encoded_value).c_str());
		}
		return static_cast<std::uint64_t>(value);
	}

	// Every value from R as an encoded value, checked. Integer and double vectors are both
	// accepted; anything else is the caller's error to report.
	std::vector<std::uint64_t> checked_values(
		const logmu::naxp& expression,
		SEXP values,
		bool allow_missing,
		const std::string& argument)
	{
		const std::uint64_t max_encoded_value = expression.max_encoded_value();
		const R_xlen_t count = Rf_xlength(values);
		std::vector<std::uint64_t> result(static_cast<std::size_t>(count));
		if (TYPEOF(values) == INTSXP)
		{
			const int* data = INTEGER(values);
			for (R_xlen_t index = 0; index < count; ++index)
			{
				const int value = data[index];
				result[static_cast<std::size_t>(index)] = checked_value(
					static_cast<double>(value),
					value == NA_INTEGER,
					index,
					max_encoded_value,
					allow_missing,
					argument);
			}
		}
		else if (TYPEOF(values) == REALSXP)
		{
			const double* data = REAL(values);
			for (R_xlen_t index = 0; index < count; ++index)
			{
				const double value = data[index];
				result[static_cast<std::size_t>(index)] = checked_value(
					value,
					ISNAN(value),
					index,
					max_encoded_value,
					allow_missing,
					argument);
			}
		}
		else
		{
			cpp11::stop("`%s` must be integer or double.", argument.c_str());
		}
		return result;
	}

	// Encoded values as an R vector of the naxp's storage type. The caller has already
	// checked the storage is not too large.
	cpp11::sexp encoded_vector(const logmu::naxp& expression, const std::vector<std::uint64_t>& values)
	{
		const R_xlen_t count = static_cast<R_xlen_t>(values.size());
		if (storage_of(expression) == value_storage::integer)
		{
			cpp11::writable::integers result(count);
			for (R_xlen_t index = 0; index < count; ++index)
			{
				result[index] = static_cast<int>(values[static_cast<std::size_t>(index)]);
			}
			return result;
		}
		cpp11::writable::doubles result(count);
		for (R_xlen_t index = 0; index < count; ++index)
		{
			result[index] = static_cast<double>(values[static_cast<std::size_t>(index)]);
		}
		return result;
	}
}

// The version of the vendored naxp library.
[[cpp11::register]]
cpp11::r_string cpp_naxp_version()
{
	return cpp11::r_string(naxp_version());
}

// Parses a pattern. On success the list holds `pointer`; otherwise it holds the error's
// parts and `summary`, the library's own one-line form of it.
[[cpp11::register]]
cpp11::list cpp_naxp_parse(cpp11::strings pattern)
{
	using namespace cpp11::literals;

	const std::string_view text = text_of(pattern[0]);
	logmu::naxp_error error;
	std::optional<logmu::naxp> expression = logmu::naxp::try_parse(text, &error);
	if (expression)
	{
		naxp_pointer pointer(new logmu::naxp(*expression));
		return cpp11::writable::list({"pointer"_nm = static_cast<SEXP>(pointer)});
	}
	const std::string summary = logmu::naxp_format_error(error).what();
	return cpp11::writable::list({
		"code"_nm = error.code,
		"message"_nm = error.message,
		"offset"_nm = static_cast<double>(error.offset),
		"length"_nm = static_cast<double>(error.length),
		"summary"_nm = summary,
	});
}

// The pattern of a standard naxp, looked up by the library so that ids and variants match as
// in every naxp library, or NA where there is no such standard or variant.
[[cpp11::register]]
cpp11::strings cpp_naxp_standard_pattern(cpp11::strings id, cpp11::strings variant)
{
	std::optional<logmu::naxp> expression = logmu::naxp::try_standard_naxp(text_of(id[0]), text_of(variant[0]));
	cpp11::writable::strings result(1);
	if (expression)
	{
		const std::string_view pattern = expression->pattern();
		SET_STRING_ELT(result, 0, make_string(pattern.data(), pattern.size()));
	}
	else
	{
		SET_STRING_ELT(result, 0, NA_STRING);
	}
	return result;
}

// Every standard naxp, one element per variant, as the columns of a data frame.
[[cpp11::register]]
cpp11::list cpp_naxp_all_standard_naxps()
{
	using namespace cpp11::literals;

	const std::vector<logmu::standard_naxp_variant>& variants = logmu::naxp::all_standard_naxps();
	const R_xlen_t count = static_cast<R_xlen_t>(variants.size());
	cpp11::writable::strings ids(count);
	cpp11::writable::strings names(count);
	cpp11::writable::strings variant_ids(count);
	cpp11::writable::strings patterns(count);
	cpp11::writable::strings notes(count);
	for (R_xlen_t index = 0; index < count; ++index)
	{
		const logmu::standard_naxp_variant& variant = variants[static_cast<std::size_t>(index)];
		SET_STRING_ELT(ids, index, make_string(variant.id.data(), variant.id.size()));
		SET_STRING_ELT(names, index, make_string(variant.name.data(), variant.name.size()));
		SET_STRING_ELT(variant_ids, index, make_string(variant.variant.data(), variant.variant.size()));
		SET_STRING_ELT(patterns, index, make_string(variant.pattern.data(), variant.pattern.size()));
		SET_STRING_ELT(notes, index, make_string(variant.notes.data(), variant.notes.size()));
	}
	return cpp11::writable::list({
		"id"_nm = static_cast<SEXP>(ids),
		"name"_nm = static_cast<SEXP>(names),
		"variant"_nm = static_cast<SEXP>(variant_ids),
		"pattern"_nm = static_cast<SEXP>(patterns),
		"notes"_nm = static_cast<SEXP>(notes),
	});
}

// 0 where encoded values fit an R integer, 1 where they fit a double exactly, 2 where they
// are too large for R.
[[cpp11::register]]
int cpp_naxp_storage(SEXP pointer)
{
	return static_cast<int>(storage_of(naxp_of(pointer)));
}

[[cpp11::register]]
std::string cpp_naxp_max_encoded_value_text(SEXP pointer)
{
	return std::to_string(naxp_of(pointer).max_encoded_value());
}

[[cpp11::register]]
double cpp_naxp_max_encoded_value(SEXP pointer)
{
	return static_cast<double>(naxp_of(pointer).max_encoded_value());
}

[[cpp11::register]]
int cpp_naxp_max_length(SEXP pointer)
{
	return static_cast<int>(naxp_of(pointer).max_length());
}

[[cpp11::register]]
cpp11::sexp cpp_naxp_encode(SEXP pointer, cpp11::strings text)
{
	const logmu::naxp& expression = naxp_of(pointer);
	const R_xlen_t count = text.size();
	std::vector<std::uint64_t> values(static_cast<std::size_t>(count));
	for (R_xlen_t index = 0; index < count; ++index)
	{
		const SEXP element = text[index];
		if (element != NA_STRING)
		{
			values[static_cast<std::size_t>(index)] = expression.encode(text_of(element));
		}
	}
	return encoded_vector(expression, values);
}

[[cpp11::register]]
cpp11::logicals cpp_naxp_accepts(SEXP pointer, cpp11::strings text)
{
	const logmu::naxp& expression = naxp_of(pointer);
	const R_xlen_t count = text.size();
	cpp11::writable::logicals result(count);
	for (R_xlen_t index = 0; index < count; ++index)
	{
		const SEXP element = text[index];
		result[index] = cpp11::r_bool(element != NA_STRING && expression.accepts(text_of(element)));
	}
	return result;
}

[[cpp11::register]]
cpp11::strings cpp_naxp_canonical_form(SEXP pointer, cpp11::strings text)
{
	const logmu::naxp& expression = naxp_of(pointer);
	const R_xlen_t count = text.size();
	std::vector<char> buffer(expression.max_length() + 1);
	cpp11::writable::strings result(count);
	for (R_xlen_t index = 0; index < count; ++index)
	{
		const SEXP element = text[index];
		std::size_t length = 0;
		if (element != NA_STRING
			&& expression.try_canonical_form(text_of(element), buffer.data(), buffer.size(), length))
		{
			SET_STRING_ELT(result, index, make_string(buffer.data(), length));
		}
		else
		{
			SET_STRING_ELT(result, index, NA_STRING);
		}
	}
	return result;
}

// Decodes values, which may be missing; zero and NA both decode to NA.
[[cpp11::register]]
cpp11::strings cpp_naxp_decode(SEXP pointer, SEXP values, std::string argument)
{
	const logmu::naxp& expression = naxp_of(pointer);
	const std::vector<std::uint64_t> checked = checked_values(expression, values, true, argument);
	std::vector<char> buffer(expression.max_length() + 1);
	const R_xlen_t count = static_cast<R_xlen_t>(checked.size());
	cpp11::writable::strings result(count);
	for (R_xlen_t index = 0; index < count; ++index)
	{
		const std::uint64_t value = checked[static_cast<std::size_t>(index)];
		std::size_t length = 0;
		if (value != 0 && expression.try_decode(value, buffer.data(), buffer.size(), length))
		{
			SET_STRING_ELT(result, index, make_string(buffer.data(), length));
		}
		else
		{
			SET_STRING_ELT(result, index, NA_STRING);
		}
	}
	return result;
}

// Checks bare values against a naxp and returns them in its storage type. NA is an error.
[[cpp11::register]]
cpp11::sexp cpp_naxp_check_values(SEXP pointer, SEXP values, std::string argument)
{
	const logmu::naxp& expression = naxp_of(pointer);
	return encoded_vector(expression, checked_values(expression, values, false, argument));
}

// The three relationships, or NULL where the encoding relationship could not be decided
// within the budget. A budget of zero or less means the library's default.
[[cpp11::register]]
cpp11::sexp cpp_naxp_compare(SEXP a, SEXP b, int budget)
{
	using namespace cpp11::literals;

	const int chosen_budget = budget > 0 ? budget : logmu::naxp::default_budget;
	logmu::naxp_comparison comparison;
	if (!logmu::naxp::try_compare(naxp_of(a), naxp_of(b), comparison, chosen_budget))
	{
		return R_NilValue;
	}
	cpp11::writable::strings result({
		relationship_name(comparison.accepted_text),
		relationship_name(comparison.encoding),
		relationship_name(comparison.canonical_forms),
	});
	result.names() = {"accepted_text", "encoding", "canonical_forms"};
	return result;
}

[[cpp11::register]]
int cpp_naxp_default_budget()
{
	return logmu::naxp::default_budget;
}

[[cpp11::register]]
double cpp_naxp_first_divergent_value(SEXP a, SEXP b)
{
	return static_cast<double>(logmu::naxp::first_divergent_value(naxp_of(a), naxp_of(b)));
}

// `language` and `value_type` are the enums' numeric values, checked by the caller.
[[cpp11::register]]
std::string cpp_naxp_emit(
	SEXP pointer,
	int language,
	std::string prefix,
	int value_type,
	std::string initial_indent,
	std::string new_line,
	std::string indent)
{
	return naxp_of(pointer).emit(
		static_cast<logmu::output_language>(language),
		prefix,
		static_cast<logmu::naxp_value_type>(value_type),
		initial_indent,
		new_line,
		indent);
}
