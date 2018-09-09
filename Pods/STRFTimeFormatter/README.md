## Overview

`STRFTimeFormatter` is a simple class that encapsulates the `strftime_l(3)` and `strptime_l(3)` functions in an interface that replicates that of `NSDateFormatter`. This class is to be used to convert machine generated dates in an efficient manner as mentioned in [issue 9 of objc.io](http://www.objc.io/issue-9/string-localization.html) (see the section on *Parsing Machine Input*).

## Installation

Installation is best done via [cocoapods](http://cocoapods.org).

### Podfile

    pod 'STRFTimeFormatter'

## Usage

`STRFTimeFormatter` replicates the convenience functions of the `NSDateFormatter` class:

    - (NSDate *)dateFromString:(NSString *)string;
    - (NSString *)stringFromDate:(NSDate *)date;

The only optional setup is to change the `formatString` used by the `strftime_l(3)` and `strptime_l(3)` functions. See the [`strftime(3)` man page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/strftime.3.html) for possible format specifiers. The default is `%Y-%m-%dT%H:%M:%S%z`, which corresponds to a string format such as `2014-02-18T12:42:07+0000`.

`STRFTimeFormatter` is not a subclass of `NSFormatter`, for two reasons:

* It should be cheap to allocate an instance.
* Laziness.

## The Point

`strptime_l(3)` is a **lot** faster than `-[NSDateFormatter dateFromString:]`, but it's a pain to use. `STRFTimeFormatter` gives you the huge performance bump when dealing fixed format date strings, but without the hassle of dropping into C libraries all the time (or having to put `#import <xlocale.h>` everywhere - how ugly).

Here's the proof:

    #import <Foundation/Foundation.h>
    #import <xlocale.h>

    #define LOG_SAMPLES

    void startTimer(NSDate **timer);
    void finishTimer(NSDate *timer, NSString *message);

    int main(int argc, char *argv[])
    {
        @autoreleasepool {
            
            NSUInteger numberOfDatesToCreate = 604800;
            NSLog(@"Creating %llu date strings.", (unsigned long long)numberOfDatesToCreate);
            
            NSDate *timer;
            
            // string format to be used by strftime_l and strptime_l
            const char *formatString = "%Y-%m-%dT%H:%M:%S%z";
            
            // date formatter to be used
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            
            NSMutableArray *strfStrings = [[NSMutableArray alloc] init];
            NSMutableArray *formatterStrings = [[NSMutableArray alloc] init];
            
            startTimer(&timer);
            
            for (NSUInteger i = 0; i < numberOfDatesToCreate; i++) {
                
                @autoreleasepool {
                    
                    // create the date anyway, lets keep the comparison fair :)
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(1392595200 + i)];
                    
                    time_t timeInterval = [date timeIntervalSince1970];
                    struct tm time = *localtime(&timeInterval);
                    char buffer[80];
                    
                    strftime_l(buffer, sizeof(buffer), formatString, &time, NULL);
                    NSString *dateString = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                    
    #ifdef LOG_SAMPLES
                    if (i % 86400 == 0) {
                        NSLog(@"Sample: %@", dateString);
                    }
    #endif
                    
                    [strfStrings addObject:dateString];
                }
            }
            
            finishTimer(timer, @"Created date strings using strftime_l(3)");
            startTimer(&timer);
            
            for (NSUInteger i = 0; i < numberOfDatesToCreate; i++) {
                
                @autoreleasepool {
                    
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(1392595200 + i)];
                    NSString *dateString = [dateFormatter stringFromDate:date];
                    
    #ifdef LOG_SAMPLES
                    if (i % 86400 == 0) {
                        NSLog(@"Sample: %@", dateString);
                    }
    #endif
                    
                    [formatterStrings addObject:dateString];
                }
            }
            
            finishTimer(timer, @"Created date strings using NSDateFormatter");
            
            NSLog(@"Parsing %llu date strings.", (unsigned long long)numberOfDatesToCreate);
            
            startTimer(&timer);
            
            for (NSUInteger i = 0; i < numberOfDatesToCreate; i++) {
                
                NSString *dateString = strfStrings[i];
                
                struct tm time;
                strptime_l([dateString cStringUsingEncoding:NSASCIIStringEncoding], formatString, &time, NULL);
                time_t timeInterval = mktime(&time);
                
                // create the date anyway, lets keep the comparison fair :)
                __unused NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                
    #ifdef LOG_SAMPLES
                if (i % 86400 == 0) {
                    NSLog(@"Sample: %@", date);
                }
    #endif
            }
            
            finishTimer(timer, @"Parsed date strings using strptime_l(3)");
            startTimer(&timer);
            
            for (NSUInteger i = 0; i < numberOfDatesToCreate; i++) {
                
                NSString *dateString = formatterStrings[i];
                __unused NSDate *date = [dateFormatter dateFromString:dateString];
                
    #ifdef LOG_SAMPLES
                if (i % 86400 == 0) {
                    NSLog(@"Sample: %@", date);
                }
    #endif
            }
            
            finishTimer(timer, @"Parsed date strings using NSDateFormatter");
        }
    }

    void startTimer(NSDate **timer)
    {
        *timer = [NSDate date];
    }

    void finishTimer(NSDate *timer, NSString *message)
    {
        NSTimeInterval interval = -[timer timeIntervalSinceNow];
        NSLog(@"%@ -- %g seconds", message, interval);
    }

