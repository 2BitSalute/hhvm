<?hh // partial

/**
 * Perform a regular expression search and replace.
 *
 * preg_filter() is identical to preg_replace() except it only returns the
 * (possibly transformed) subjects where there was a match. For details
 * about how this function works, read the preg_replace() documentation.
 *
 * @return mixed - preg_filter() returns an array if the subject parameter
 * is an array, or a string otherwise. If no matches are found or an error
 * occurred, an empty array is returned when subject is an array or NULL
 * otherwise.
 */
<<__Native>>
function preg_filter(mixed $pattern,
                     mixed $replacement,
                     mixed $subject,
                     int $limit = -1,
                     ?int &$count = null): mixed;

/**
 * Return array entries that match the pattern
 *
 * @param string $pattern - The pattern to search for, as a string.
 * @param array $input - The input array.
 * @param int $flags - If set to PREG_GREP_INVERT, this function returns
 *   the elements of the input array that do not match the given pattern.
 *
 * @return array - Returns an array indexed using the keys from the input
 *   array.
 */
<<__Native>>
function preg_grep(string $pattern,
                   varray_or_darray $input,
                   int $flags = 0): mixed;

/**
 * Returns the error code of the last PCRE regex execution
 *
 * @return int - Returns one of the following constants (explained on
 *   their own page):  PREG_NO_ERROR PREG_INTERNAL_ERROR
 *   PREG_BACKTRACK_LIMIT_ERROR (see also pcre.backtrack_limit)
 *   PREG_RECURSION_LIMIT_ERROR (see also pcre.recursion_limit)
 *   PREG_BAD_UTF8_ERROR PREG_BAD_UTF8_OFFSET_ERROR (since PHP 5.3.0)
 */
<<__Native>>
function preg_last_error(): int;

/**
 * Perform a global regular expression match
 *
 * @param string $pattern - The pattern to search for, as a string.
 * @param string $subject - The input string.
 * @param array $matches - Array of all matches in multi-dimensional
 *   array ordered according to flags.
 * @param int $flags - Can be a combination of the following flags (note
 *   that it doesn't make sense to use PREG_PATTERN_ORDER together with
 *   PREG_SET_ORDER):   PREG_PATTERN_ORDER   Orders results so that
 *   $matches[0] is an array of full pattern matches, $matches[1] is an
 *   array of strings matched by the first parenthesized subpattern, and so
 *   on.           So, $out[0] contains array of strings that matched full
 *   pattern, and $out[1] contains array of strings enclosed by tags.
 *   PREG_SET_ORDER   Orders results so that $matches[0] is an array of
 *   first set of matches, $matches[1] is an array of second set of
 *   matches, and so on.             PREG_OFFSET_CAPTURE   If this flag is
 *   passed, for every occurring match the appendant string offset will
 *   also be returned. Note that this changes the value of matches into an
 *   array where every element is an array consisting of the matched string
 *   at offset 0 and its string offset into subject at offset 1.       If
 *   no order flag is given, PREG_PATTERN_ORDER is assumed.
 * @param int $offset - Normally, the search starts from the beginning of
 *   the subject string. The optional parameter offset can be used to
 *   specify the alternate place from which to start the search (in bytes).
 *      Using offset is not equivalent to passing substr($subject, $offset)
 *   to preg_match_all() in place of the subject string, because pattern
 *   can contain assertions such as ^, $ or (?=x). See preg_match() for
 *   examples.
 *
 * @return int - Returns the number of full pattern matches (which might
 *   be zero), or FALSE if an error occurred.
 */
<<__Native>>
function preg_match_all(string $pattern,
                        string $subject,
                        ?array &$matches = null,
                        int $flags = 0,
                        int $offset = 0): mixed;

/**
 * Perform a regular expression match
 *
 * @param string $pattern - The pattern to search for, as a string.
 * @param string $subject - The input string.
 * @param array $matches - If matches is provided, then it is filled with
 *   the results of search. $matches[0] will contain the text that matched
 *   the full pattern, $matches[1] will have the text that matched the
 *   first captured parenthesized subpattern, and so on.
 * @param int $flags - flags can be the following flag:
 *   PREG_OFFSET_CAPTURE   If this flag is passed, for every occurring
 *   match the appendant string offset will also be returned. Note that
 *   this changes the value of matches into an array where every element is
 *   an array consisting of the matched string at offset 0 and its string
 *   offset into subject at offset 1.
 * @param int $offset - Normally, the search starts from the beginning of
 *   the subject string. The optional parameter offset can be used to
 *   specify the alternate place from which to start the search (in bytes).
 *      Using offset is not equivalent to passing substr($subject, $offset)
 *   to preg_match() in place of the subject string, because pattern can
 *   contain assertions such as ^, $ or (?=x). Compare:         while this
 *   example      will produce
 *
 * @return int - preg_match() returns 1 if the pattern matches given
 *   subject, 0 if it does not, or FALSE if an error occurred.
 */
<<__Native>>
function preg_match(string $pattern,
                    string $subject,
                    ?array &$matches = null,
                    int $flags = 0,
                    int $offset = 0): mixed;

/**
 * Quote regular expression characters
 *
 * @param string $str - The input string.
 * @param string $delimiter - If the optional delimiter is specified, it
 *   will also be escaped. This is useful for escaping the delimiter that
 *   is required by the PCRE functions. The / is the most commonly used
 *   delimiter.
 *
 * @return string - Returns the quoted (escaped) string.
 */
<<__IsFoldable, __Rx, __Native>>
function preg_quote(string $str,
                    ?string $delimiter = NULL): string;

/**
 * Perform a regular expression search and replace using a callback
 *
 * @param mixed $pattern - The pattern to search for. It can be either a
 *   string or an array with strings.
 * @param callable $callback - A callback that will be called and passed
 *   an array of matched elements in the subject string. The callback
 *   should return the replacement string. This is the callback signature:
 *     stringhandler arraymatches    You'll often need the callback
 *   function for a preg_replace_callback() in just one place. In this case
 *   you can use an anonymous function to declare the callback within the
 *   call to preg_replace_callback(). By doing it this way you have all
 *   information for the call in one place and do not clutter the function
 *   namespace with a callback function's name not used anywhere else.
 *   preg_replace_callback() and anonymous function
 * @param mixed $subject - The string or an array with strings to search
 *   and replace.
 * @param int $limit - The maximum possible replacements for each pattern
 *   in each subject string. Defaults to -1 (no limit).
 * @param int $count - If specified, this variable will be filled with
 *   the number of replacements done.
 *
 * @return mixed - preg_replace_callback() returns an array if the
 *   subject parameter is an array, or a string otherwise. On errors the
 *   return value is NULL   If matches are found, the new subject will be
 *   returned, otherwise subject will be returned unchanged.
 */
<<__Native>>
function preg_replace_callback(mixed $pattern,
                               mixed $callback,
                               mixed $subject,
                               int $limit = -1,
                               ?int &$count = null): mixed;

/**
 * Perform a regular expression search and replace using an associative array of
 * pattern and callback key/value pairs. In array order, each callback is called
 * for the pattern in question, and the return value is then used as the subject
 * for the next pattern/callback pair. This function alleviates the need for a
 * a bunch of branching checks that are required if you called something like
 * preg_replace_callback() that uses a single callback.
 *
 * @param mixed $patterns_and_callbacks - An associative array mapping patterns
 *   (keys) to callbacks (values). Each callback that will be called will be
 *   passed an array of matched elements in the subject string. The callback
 *   should return the replacement string. This is the callback signature:
 *     `string handler (array matches)`
 *   If you need the callback function just in one place in the array, use an
 *   anonymous function to declare the callback within the call to
 *   preg_replace_callback_array(). By doing it this way you have all the
 *   information for the call in one place and do not clutter the function
 *   namespace with a callback function's name not used anywhere else.
 * @param mixed $subject - The string or an array with strings to search
 *   and replace.
 * @param int $limit - The maximum possible replacements for each pattern
 *   in each subject string. Defaults to -1 (no limit).
 * @param int $count - If specified, this variable will be filled with
 *   the number of replacements done.
 *
 * @return mixed - preg_replace_callback_array() returns an array if the
 *   subject parameter is an array, or a string otherwise. On errors the
 *   return value is NULL   If matches are found, the new subject will be
 *   returned, otherwise subject will be returned unchanged.
 */
<<__Native>>
function preg_replace_callback_array(mixed $patterns_and_callbacks,
                                     mixed $subject,
                                     int $limit = -1,
                                     ?int &$count = null): mixed;
/**
 * Perform a regular expression search and replace
 *
 * @param mixed $pattern - The pattern to search for. It can be either a
 *   string or an array with strings.   Several PCRE modifiers are also
 *   available, including the deprecated 'e' (PREG_REPLACE_EVAL), which is
 *   specific to this function.
 * @param mixed $replacement - The string or an array with strings to
 *   replace. If this parameter is a string and the pattern parameter is an
 *   array, all patterns will be replaced by that string. If both pattern
 *   and replacement parameters are arrays, each pattern will be replaced
 *   by the replacement counterpart. If there are fewer elements in the
 *   replacement array than in the pattern array, any extra patterns will
 *   be replaced by an empty string.   replacement may contain references
 *   of the form \\n or (since PHP 4.0.4) $n, with the latter form being
 *   the preferred one. Every such reference will be replaced by the text
 *   captured by the n'th parenthesized pattern. n can be from 0 to 99, and
 *   \\0 or $0 refers to the text matched by the whole pattern. Opening
 *   parentheses are counted from left to right (starting from 1) to obtain
 *   the number of the capturing subpattern. To use backslash in
 *   replacement, it must be doubled ("\\\\" PHP string).   When working
 *   with a replacement pattern where a backreference is immediately
 *   followed by another number (i.e.: placing a literal number immediately
 *   after a matched pattern), you cannot use the familiar \\1 notation for
 *   your backreference. \\11, for example, would confuse preg_replace()
 *   since it does not know whether you want the \\1 backreference followed
 *   by a literal 1, or the \\11 backreference followed by nothing. In this
 *   case the solution is to use \${1}1. This creates an isolated $1
 *   backreference, leaving the 1 as a literal.   When using the deprecated
 *   e modifier, this function escapes some characters (namely ', ", \ and
 *   NULL) in the strings that replace the backreferences. This is done to
 *   ensure that no syntax errors arise from backreference usage with
 *   either single or double quotes (e.g. 'strlen(\'$1\')+strlen("$2")').
 *   Make sure you are aware of PHP's string syntax to know exactly how the
 *   interpreted string will look.
 * @param mixed $subject - The string or an array with strings to search
 *   and replace.   If subject is an array, then the search and replace is
 *   performed on every entry of subject, and the return value is an array
 *   as well.
 * @param int $limit - The maximum possible replacements for each pattern
 *   in each subject string. Defaults to -1 (no limit).
 * @param int $count - If specified, this variable will be filled with
 *   the number of replacements done.
 *
 * @return mixed - preg_replace() returns an array if the subject
 *   parameter is an array, or a string otherwise.   If matches are found,
 *   the new subject will be returned, otherwise subject will be returned
 *   unchanged or NULL if an error occurred.
 */
<<__Native>>
function preg_replace(mixed $pattern,
                      mixed $replacement,
                      mixed $subject,
                      int $limit = -1,
                      ?int &$count = null): mixed;

/**
 * Split string by a regular expression
 *
 * @param string $pattern - The pattern to search for, as a string.
 * @param string $subject - The input string.
 * @param int $limit - If specified, then only substrings up to limit are
 *   returned with the rest of the string being placed in the last
 *   substring. A limit of -1, 0 or NULL means "no limit" and, as is
 *   standard across PHP, you can use NULL to skip to the flags parameter.
 * @param int $flags - flags can be any combination of the following
 *   flags (combined with the | bitwise operator):   PREG_SPLIT_NO_EMPTY
 *   If this flag is set, only non-empty pieces will be returned by
 *   preg_split().     PREG_SPLIT_DELIM_CAPTURE   If this flag is set,
 *   parenthesized expression in the delimiter pattern will be captured and
 *   returned as well.     PREG_SPLIT_OFFSET_CAPTURE   If this flag is set,
 *   for every occurring match the appendant string offset will also be
 *   returned. Note that this changes the return value in an array where
 *   every element is an array consisting of the matched string at offset 0
 *   and its string offset into subject at offset 1.
 *
 * @return array - Returns an array containing substrings of subject
 *   split along boundaries matched by pattern.
 */
<<__Native>>
function preg_split(string $pattern,
                    string $subject,
                    mixed $limit = null,
                    int $flags = 0): mixed;

/**
 * Replace regular expression
 *
 * @param string $pattern - A POSIX extended regular expression.
 * @param string $replacement - If pattern contains parenthesized
 *   substrings, replacement may contain substrings of the form \digit,
 *   which will be replaced by the text matching the digit'th parenthesized
 *   substring; \0 will produce the entire contents of string. Up to nine
 *   substrings may be used. Parentheses may be nested, in which case they
 *   are counted by the opening parenthesis.
 * @param string $string - The input string.
 *
 * @return string - The modified string is returned. If no matches are
 *   found in string, then it will be returned unchanged.
 */
<<__Native>>
function ereg_replace(string $pattern,
                      string $replacement,
                      string $string): string;

/**
 * Regular expression match
 *
 * @param string $pattern - Case sensitive regular expression.
 * @param string $string - The input string.
 * @param array $regs - If matches are found for parenthesized substrings
 *   of pattern and the function is called with the third argument regs,
 *   the matches will be stored in the elements of the array regs.
 *   $regs[1] will contain the substring which starts at the first left
 *   parenthesis; $regs[2] will contain the substring starting at the
 *   second, and so on. $regs[0] will contain a copy of the complete string
 *   matched.
 *
 * @return int - Returns the length of the matched string if a match for
 *   pattern was found in string, or FALSE if no matches were found or an
 *   error occurred.   If the optional parameter regs was not passed or the
 *   length of the matched string is 0, this function returns 1.
 */
<<__Native, __Deprecated('As of PHP 5.3.0, preg_match is suggested instead')>>
function ereg(string $pattern,
              string $string,
              ?array &$regs = null): mixed;

/**
 * Replace regular expression case insensitive
 *
 * @param string $pattern - A POSIX extended regular expression.
 * @param string $replacement - If pattern contains parenthesized
 *   substrings, replacement may contain substrings of the form \digit,
 *   which will be replaced by the text matching the digit'th parenthesized
 *   substring; \0 will produce the entire contents of string. Up to nine
 *   substrings may be used. Parentheses may be nested, in which case they
 *   are counted by the opening parenthesis.
 * @param string $string - The input string.
 *
 * @return string - The modified string is returned. If no matches are
 *   found in string, then it will be returned unchanged.
 */
<<__Native>>
function eregi_replace(string $pattern,
                       string $replacement,
                       string $string): string;

/**
 * Case insensitive regular expression match
 *
 * @param string $pattern - Case insensitive regular expression.
 * @param string $string - The input string.
 * @param array $regs - If matches are found for parenthesized substrings
 *   of pattern and the function is called with the third argument regs,
 *   the matches will be stored in the elements of the array regs.
 *   $regs[1] will contain the substring which starts at the first left
 *   parenthesis; $regs[2] will contain the substring starting at the
 *   second, and so on. $regs[0] will contain a copy of the complete string
 *   matched.
 *
 * @return int - Returns the length of the matched string if a match for
 *   pattern was found in string, or FALSE if no matches were found or an
 *   error occurred.   If the optional parameter regs was not passed or the
 *   length of the matched string is 0, this function returns 1.
 */
<<__Native>>
function eregi(string $pattern,
               string $string,
               ?array &$regs = null): mixed;

/**
 * Split string into array by regular expression
 *
 * @param string $pattern - Case sensitive regular expression.   If you
 *   want to split on any of the characters which are considered special by
 *   regular expressions, you'll need to escape them first. If you think
 *   split() (or any other regex function, for that matter) is doing
 *   something weird, please read the file regex.7, included in the regex/
 *   subdirectory of the PHP distribution. It's in manpage format, so
 *   you'll want to do something along the lines of man
 *   /usr/local/src/regex/regex.7 in order to read it.
 * @param string $string - The input string.
 * @param int $limit - If limit is set, the returned array will contain a
 *   maximum of limit elements with the last element containing the whole
 *   rest of string.
 *
 * @return array - Returns an array of strings, each of which is a
 *   substring of string formed by splitting it on boundaries formed by the
 *   case-sensitive regular expression pattern.   If there are n
 *   occurrences of pattern, the returned array will contain n+1 items. For
 *   example, if there is no occurrence of pattern, an array with only one
 *   element will be returned. Of course, this is also true if string is
 *   empty. If an error occurs, split() returns FALSE.
 */
<<__Native>>
function split(string $pattern,
               string $string,
               int $limit = -1): mixed;

/**
 * Split string into array by regular expression case insensitive
 *
 * @param string $pattern - Case insensitive regular expression.   If you
 *   want to split on any of the characters which are considered special by
 *   regular expressions, you'll need to escape them first. If you think
 *   spliti() (or any other regex function, for that matter) is doing
 *   something weird, please read the file regex.7, included in the regex/
 *   subdirectory of the PHP distribution. It's in manpage format, so
 *   you'll want to do something along the lines of man
 *   /usr/local/src/regex/regex.7 in order to read it.
 * @param string $string - The input string.
 * @param int $limit - If limit is set, the returned array will contain a
 *   maximum of limit elements with the last element containing the whole
 *   rest of string.
 *
 * @return array - Returns an array of strings, each of which is a
 *   substring of string formed by splitting it on boundaries formed by the
 *   case insensitive regular expression pattern.   If there are n
 *   occurrences of pattern, the returned array will contain n+1 items. For
 *   example, if there is no occurrence of pattern, an array with only one
 *   element will be returned. Of course, this is also true if string is
 *   empty. If an error occurs, spliti() returns FALSE.
 */
<<__Native>>
function spliti(string $pattern,
                string $string,
                int $limit = -1): mixed;

/**
 * Make regular expression for case insensitive match
 *
 * @param string $string - The input string.
 *
 * @return string - Returns a valid regular expression which will match
 *   string, ignoring case. This expression is string with each alphabetic
 *   character converted to a bracket expression; this bracket expression
 *   contains that character's uppercase and lowercase form. Other
 *   characters remain unchanged.
 */
<<__Native>>
function sql_regcase(string $string): string;
