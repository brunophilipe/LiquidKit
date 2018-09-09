//
//  STRFTimeFormatter.h
//
//  Copyright (c) 2014 emdentec (http://emdentec.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


/**
 *  Instances of `STRFTimeFormatter` create string representations of `NSDate` objects, and convert textual representations of dates and times into `NSDate` objects using the `strftime_l(3)` and `strptime_l(3)` functions.
 */
@interface STRFTimeFormatter : NSObject <NSCopying>


///  ------------------------
///  @name Converting Objects
///  ------------------------

/**
 *  @abstract Returns a date representation of a given string interpreted via `strptime_l(3)` using the receiver’s current settings.
 *
 *  @param string The string to parse.
 *
 *  @return A date representation of *string* interpreted via `strptime_l(3)` using the receiver’s current settings. If `dateFromString:` can not parse the string, returns `nil`.
 */
- (NSDate *)dateFromString:(NSString *)string;

/**
 *  @abstract Returns a string representation of a given date formatted via `strftime_l(3)` using the receiver’s current settings.
 *
 *  @param date The date to format.
 *
 *  @return A string representation of *date* formatted via `strftime_l(3)` using the receiver’s current settings.
 */
- (NSString *)stringFromDate:(NSDate *)date;


///  ----------------------
///  @name Managing Formats
///  ----------------------

/**
 *  @abstract Returns the format string that will be used by `strftime_l(3)` and `strptime_l(3)`.
 *
 *  @return The format string that will be used by `strftime_l(3)` and `strptime_l(3)`.
 *
 *  @see -setFormatString:
 */
- (NSString *)formatString;

/**
 *  @abstract Sets the format string that will be used by `strftime_l(3)` and `strptime_l(3)`.
 *
 *  @param formatString The format string that will be used by `strftime_l(3)` and `strptime_l(3)`.
 *
 *  @discussion See the [`strftime` man page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/strftime.3.html) for a list of available conversion specifiers. The default value is `%Y-%m-%dT%H:%M:%S%z`.
 *  
 *  Internally this value is stored as a `const char *`.
 *
 *  @see -formatString
 */
- (void)setFormatString:(NSString *)formatString;

/**
 *  @abstract Returns a boolean value indicating if the universal time locale is being used.
 *
 *  @return A boolean value indicating if the universal time locale is being used.
 *
 *  @see -setUseUniversalTimeLocale
 */
- (BOOL)useUniversalTimeLocale;

/**
 *  @abstract Sets whether the universal time locale will be used.
 *
 *  @param useUniversalTimeLocale A boolean value indicating if the universal time locale should be used.
 *
 *  @see -useUniversalTimeLocale
 */
- (void)setUseUniversalTimeLocale:(BOOL)useUniversalTimeLocale;

@end
