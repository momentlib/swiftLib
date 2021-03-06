%{
#include <stdio.h>
#include "TimeParser.h"

int yylex(void);
void yyerror(char *);

%}



%union 
{
int number;
char *string;
}

%token <number>INTEGER DTPOSITION DAYOFWEEK MONTHNUM GENERALTIME  MODIFIERS FROM LASTNEXT BEFOREAFTER HENCEAGO IN THIS NOW INTHE PLUS SETDATE
%token <string>MONTH  PASTMODIFIER WHENTIME TYPENAMES DTMODIFIERS ARTICLEPREP  MILITARYTIME

%%


program:    { setCurrentTime(); 
    //NSLog(@"Parsing Started");
}
|
program expr         { 

        

        time_t curtime2 = mktime(str_time);

//        NSLog(@"UNIXTIMESTAMP = %d \n", curtime2);  
//        NSLog(@"perty time = %s\n", asctime(str_time));
//        NSLog(@"modifier num = %d", *mymodifier.changePointer);

        $<number>$ = (int)curtime2;

        for(int i=0; i<9; i++){
            fromChangeAmount[i] += changeAmount[i];
            changeAmount[i] = 0;            
        }

        set_time.tm_sec = temp_time.tm_sec >=0 ? temp_time.tm_sec : set_time.tm_sec;
        set_time.tm_min = temp_time.tm_min >=0 ? temp_time.tm_min : set_time.tm_min;
        set_time.tm_hour = temp_time.tm_hour >=0 ? temp_time.tm_hour : set_time.tm_hour;
        set_time.tm_mday = temp_time.tm_mday >=0 ? temp_time.tm_mday : set_time.tm_mday;
        set_time.tm_wday = temp_time.tm_wday >= 0 ? temp_time.tm_wday : set_time.tm_wday;
        set_time.tm_mon = temp_time.tm_mon >= 0  ? temp_time.tm_mon : set_time.tm_mon;
        set_time.tm_year = temp_time.tm_year >= 0 ? temp_time.tm_year : set_time.tm_year;

    
//    printf("temp time = %s", asctime(&temp_time));
    
        temp_time.tm_sec = -1;
        temp_time.tm_min = -1;
        temp_time.tm_hour = -1;
        temp_time.tm_mday = -1;
        temp_time.tm_wday = -1;
        temp_time.tm_mon = -1;
        temp_time.tm_year = -1;

        finalSpecAmount[0] = specAmount[0] != 0 ? specAmount[0] : finalSpecAmount[0];
        finalSpecAmount[1] = specAmount[1] != 0 ? specAmount[1] : finalSpecAmount[1];
        finalSpecAmount[2] = specAmount[2] != 0 ? specAmount[2] : finalSpecAmount[2];


//        NSLog(@"topLevel change amount = %s\n", join_strings(fromChangeAmount, ",", 9));
//        NSLog(@"topLevel spec amount = %s\n", join_strings(fromModifier.specAmount, ",", 3));
//        NSLog(@"topLevel spec value = %s\n", join_strings(fromModifier.specValue, ",", 3));
} 

;

expr:

expr BEFOREAFTER
{

//    NSLog(@"inside before = %s\n", join_strings(fromModifier.amount, ",", 9));

    if($<number>2 == -1)
    {
        int i=0;        
        for(i=0; i < 8; i++)
        {
            mymodifier.amount[i] = mymodifier.amount[i]>0 ? -mymodifier.amount[i] : mymodifier.amount[i];
        }
        for(int j=0; j<3; j++)
        {
            if(mymodifier.specValue[j] >=0)
                mymodifier.specAmount[j] *= -1;
        }
    }
    int j=0;
    for(j=0; j<3; j++)
    {
        if(mymodifier.specValue[j] >= 0)
        {
            fromModifier.specAmount[j] = mymodifier.specAmount[j];
            fromModifier.specValue[j] = mymodifier.specValue[j];
            mymodifier.specValue[j] = -1;
            mymodifier.specAmount[j] = 0;
        }
    }
    int i = 0;
    for(i=0; i < 8; i++)
    {
        fromChangeAmount[i] += mymodifier.amount[i];
        mymodifier.amount[i] = 0;
    }
}
|
FROM expr     {   

    setFinalTime(&temp_time, specAmount, changeAmount);
    time_t tempTime = mktime(str_time);
    
    str_time= localtime(&tempTime);
    
    for(int i=0; i<7; i++){
        *timePointer[i] += mymodifier.amount[i];
        mymodifier.amount[i] = 0;
    }

    if(mymodifier.specValue[1])
    {
//        NSLog(@"spec amount in from= %d", mymodifier.specAmount[1]);
        setDayOfWeek(mymodifier.specValue[1], mymodifier.specAmount);
        mymodifier.specValue[1] = -1;
        mymodifier.specAmount[1] = 0;
    }

}
|
SETDATE     { }
|
ARTICLEPREP {}
| 
IN      { }
|
THIS    { }
|
NOW     { }
|
INTEGER     {                                  /********  ex. 6 (means the time if only a number)      ******/

        if(fromChangeAmount[8] && fromChangeAmount[8] != 'm')
        {
            if($<number>1 < 12) $<number>1 += 12;
            else if($<number>1 == 12) $<number>1 = 0;
        }
        temp_time.tm_hour = $<number>1;
        temp_time.tm_min = 0;
        temp_time.tm_sec = 0;    
}

|
MONTHNUM           
{                                    /***** ex. "June"  ******/
        temp_time.tm_mon = $<number>1;   
        temp_time.tm_mday = 1;
}
|
DAYOFWEEK                                               /*****  ex.  "Friday"    *****/
{
    if($<number>1==-1) changeAmount[3] = -1;
    else if($<number>1 == 8) changeAmount[3] = 1;
    else if($<number>1 == 0) changeAmount[3] = 0;
    else
      temp_time.tm_wday = $<number>1-1;
}
|
IN INTEGER
{
    if($<number>2 > 1000)
        temp_time.tm_year = $<number>2-1900;
    $<number>$ = 6;
}
|

IN MILITARYTIME
{
    char *timeparts = strtok($<string>2, ":");
    char thedate[5] = "";
    int actualdate= 0;
    strncat(thedate, timeparts, 2);
    timeparts = strtok (NULL, ":");
    strncat(thedate, timeparts, 2);
    thedate[4] = '\0';
    actualdate= atoi(thedate);
    
    temp_time.tm_year = actualdate-1900;
    $<number>$ = 6;
}
|
IN INTEGER TYPENAMES    {                        /********  ex. "in 3 days" or "in 5 weeks" or "in 8 hours"     ******/
    if($<number>3 == 4){
        $<number>3 = 3;
        $<number>2 *= 7;
    }   
    changeAmount[$<number>3] = $<number>2;
}
|
TYPENAMES {
    if ($<number>1 == 3)
    {
        mymodifier.amount[$<number>1] += 1;
    }
}
|

INTEGER TYPENAMES   {                            /********  ex. "3 days"  mostly used with "before" or "after" as in "3 days before yesterday" ****/
    if($<number>2 == 4)
    {
        $<number>1 *= 7;
        $<number>2 = 3;
    }
//    changeAmount[$<number>2] = $<number>1;
    mymodifier.amount[$<number>2] += $<number>1;

}

|

INTEGER TYPENAMES HENCEAGO   {                           /******* ex.  "3 days ago" or "5 years hence"    ******/
    if($<number>2 == 4){
        $<number>1 *= 7;
        $<number>2 = 3;
    }   
    changeAmount[$<number>2] = $<number>1*$<number>3;
}

|
INTEGER generalTimes                                    /******* ex. "3 mornings"  mainly used with "before" or "after" *****/
{
    mymodifier.amount[3] += $<number>1;
}
|
INTEGER generalTimes HENCEAGO                           /**** ex. "3 mornings ago" or "5 afternoons hence" *****/
{
    changeAmount[3] = $<number>1*$<number>3;
}

|
LASTNEXT TYPENAMES   {                           /********** ex.  "Last Month" or "Next Year"   *******/
    $<number>$ = 0;
    if($<number>2 == 4){
        $<number>2 = 7;
        $<number>$ = 4;
    }   
    changeAmount[$<number>2] = $<number>1;
}
|
LASTNEXT DAYOFWEEK   {                          /********  ex. "last friday"  or "next friday"      ******/
    if($<number>2 > 0 && $<number>2 < 8)
      temp_time.tm_wday = $<number>2-1;
     specAmount[1] = $<number>1;
    if($<number>1 >0)
        changeAmount[7] = $<number>1;
}

|
LASTNEXT MONTHNUM                                /********  ex. "last May"  or "next May"      ******/
{
    if($<number>1 >0) $<number>2 += 12;
    temp_time.tm_mon = $<number>2;
    specAmount[0] = $<number>1;
}

|
INTEGER INTHE generalTimes  {                       /********  ex. " 6 in the morning"      ******/

        if($<number>3 > 0)
        {
            if($<number>1 < 12)
                temp_time.tm_hour = $<number>1+12;
        
            else if($<number>1 == 12)
                temp_time.tm_hour = 0;
        }
        else
        {
            temp_time.tm_hour = $<number>1;
        }
    

    specAmount[2] = 1;
}
|
INTEGER THIS generalTimes  {                       /********  ex. " 6 this morning"      ******/

    if($<number>3 > 0)
    {
        if($<number>1 < 12)
            temp_time.tm_hour = $<number>1+12;
        else if($<number>1 == 12)
            temp_time.tm_hour = 0;
    }
    else
    {
        temp_time.tm_hour = $<number>1;
    }
    specAmount[2] = 0;
}
|

INTHE generalTimes  {                                 /********  ex. "in the morning"      ******/
//    NSLog(@"just in the morning");
    specAmount[2] = 1;
}
|
whenTime        {      }

|

whenTime INTHE generalTimes                        /*******   4:30 in the afternoon   *******/
{
    if($<number>3 > 0)
    {
        if(temp_time.tm_hour < 12)
            temp_time.tm_hour += 12;

        else if(temp_time.tm_hour == 12)
            temp_time.tm_hour = 0;
    }
        specAmount[2] = 1;
}
|
generalTimes   {}                                   /****** ex. "morning"       *******/
|

LASTNEXT generalTimes                               /******* ex. "last night"   **********/
{
    changeAmount[3] = $<number>1;
}
|

whenTime LASTNEXT generalTimes                     /******  ex. "7:30 last night"   ********/
{
    changeAmount[3] = $<number>2;
    specAmount[2] = 0;
}
|
whenTime LASTNEXT DAYOFWEEK                        /******  ex. "7:30pm last Tuesday"   ********/
{
    if($<number>3 > 0 && $<number>3 < 8)
        temp_time.tm_wday = $<number>3-1;
    specAmount[1] = $<number>2;

}
|
whenTime THIS generalTimes                          /*********   3:30 this morning       *********/
{
    if($<number>3 > 0)
    {
        if(temp_time.tm_hour < 12)
            temp_time.tm_hour += 12;

        else if(temp_time.tm_hour == 12)
            temp_time.tm_hour = 0;
    }
    specAmount[2] = 0;
}

|
DTPOSITION TYPENAMES expr                                   /******* ex.  "4th day last week", "3rd month next year"   *******/
{
    switch($<number>2)
    {
        case 3:
        {
            if($<number>3 == 4) $<number>1 -=1;
            else if($<number>3 == 6) temp_time.tm_mon = 0;
            temp_time.tm_mday = $<number>1;
        }
        break;
        case 4:
        {
            temp_time.tm_mday = 1;
            specAmount[1] = $<number>1-1;
        }
        break;
        case 5:
            temp_time.tm_mon = $<number>1-1;
        break;
    }
}
|
DTPOSITION DAYOFWEEK expr                                  /******* ex.  "4th saturday next month", "3rd wed. in November"   *******/
{
    if($<number>2>0 && $<number>2 < 8)
    {
        temp_time.tm_mday = 0;
        temp_time.tm_wday = $<number>2-1;
        specAmount[1] = $<number>1;
    }
}


|

specAmountDayOrMonth    { //NSLog(@"spec amount"); 
}


;




specAmountDayOrMonth :
INTEGER DAYOFWEEK                      /**** ex. "3 Fridays"  used with "before or after" "2 tues after next thurs" ****/
{
    if($<number>2 > 0 && $<number>2 < 8)
    {
        mymodifier.specAmount[1] = $<number>1;
        mymodifier.specValue[1] = $<number>2-1;
    }
}
|
INTEGER DAYOFWEEK HENCEAGO     {                         /***** ex. "3 fridays hence"   ****/
    if($<number>2 > 0 && $<number>2 < 8)
        temp_time.tm_wday = $<number>2-1;
    specAmount[1] = $<number>1*$<number>3;
}
|
INTEGER MONTHNUM HENCEAGO      {                        /***** ex.  "3 Junes ago"    ******/
    temp_time.tm_mon = $<number>2;
    specAmount[0] = $<number>1*$<number>3;
}
|
INTEGER MONTHNUM INTEGER                               /****  ex. "3 june 1997"   ******/
{
    temp_time.tm_mon = $<number>2;
    temp_time.tm_mday = $<number>1;
    if($<number>3 < 1000)
    {
        if($<number>3 < 15)
            $<number>3 += (2000-1900);
    }
    temp_time.tm_year = $<number>3;
}
|
INTEGER MONTHNUM MILITARYTIME            /****  ex. "3 june 2011"  (had to do another to differentiate between military time and Year)  ******/
{
    char *timeparts = strtok($<string>3, ":");
    char thedate[5] = "";
    int actualdate= 0;
    strncat(thedate, timeparts, 2);
    timeparts = strtok (NULL, ":");
    strncat(thedate, timeparts, 2);
    thedate[4] = '\0';
    actualdate= atoi(thedate);

    temp_time.tm_mon = $<number>2;
    temp_time.tm_mday = $<number>1;
    temp_time.tm_year = actualdate-1900;
}
|
MONTHNUM INTEGER                                        /****  ex. "june 3"   ******/
{
    temp_time.tm_mon = $<number>1;
    if($<number>2 >1900)
        temp_time.tm_year = $<number>2-1900;
    else
        temp_time.tm_mday = $<number>2;

}
|
MONTHNUM MILITARYTIME                                        /****  ex. "june 2008"   ******/
{
    char *timeparts = strtok($<string>2, ":");
    char thedate[5] = "";
    int actualdate= 0;
    strncat(thedate, timeparts, 2);
    timeparts = strtok (NULL, ":");
    strncat(thedate, timeparts, 2);
    thedate[4] = '\0';
    actualdate= atoi(thedate);

    temp_time.tm_mon = $<number>1;
    temp_time.tm_year = actualdate-1900;
}
|
MONTHNUM DTPOSITION                                     /****  ex. "june 3rd"   ******/
{
    temp_time.tm_mon = $<number>1;
    temp_time.tm_mday = $<number>2;
}
|
MONTHNUM DTPOSITION INTEGER                             /***** ex. "june 3rd 1997"  *****/
{
    if($<number>3 < 1000)
    {
        if($<number>3 < 15)
            $<number>3 += (2000-1900);
    }
    temp_time.tm_mon = $<number>1;
    temp_time.tm_mday = $<number>2;
    temp_time.tm_year = $<number>3;
}
|
MONTHNUM INTEGER INTEGER                                /****  ex. "june 3 1997"   ******/
{
//    NSLog(@"date = %d", $<number>3);
    if($<number>3 < 1000)
    {
        if($<number>3 < 15)
            $<number>3 += (2000-1900);
    }
    temp_time.tm_mon = $<number>1;
    temp_time.tm_mday = $<number>2;
    temp_time.tm_year = $<number>3;
}
|
MONTHNUM DTPOSITION MILITARYTIME
{
    char *timeparts = strtok($<string>3, ":");
    char thedate[5] = "";
    int actualdate= 0;
    strncat(thedate, timeparts, 2);
    timeparts = strtok (NULL, ":");
    strncat(thedate, timeparts, 2);
    thedate[4] = '\0';
    actualdate= atoi(thedate);


    temp_time.tm_mon = $<number>1;
    temp_time.tm_mday = $<number>2;
    temp_time.tm_year = actualdate-1900;
}
|
MONTHNUM INTEGER MILITARYTIME
{
char *timeparts = strtok($<string>3, ":");
char thedate[5] = "";
int actualdate= 0;
strncat(thedate, timeparts, 2);
timeparts = strtok (NULL, ":");
strncat(thedate, timeparts, 2);
thedate[4] = '\0';
actualdate= atoi(thedate);

temp_time.tm_mon = $<number>1;
temp_time.tm_mday = $<number>2;
temp_time.tm_year = actualdate-1900;
}
;


generalTimes:                                   /****** ex. "morning", "afternoon"  ********/
GENERALTIME {
    $<number>$ = 1;
    if(temp_time.tm_hour < 0)
    {
        switch($<number>1)
        {
            case 'm':
            {
                temp_time.tm_hour = 7;
                $<number>$ = 0;
            }
            break;
            case 'a':
            {
                temp_time.tm_hour = 15;
            }
            break;
            case 'e':
            {
                temp_time.tm_hour = 18;
            }
            break;
            case 'n':
            {
                temp_time.tm_hour = 21;
            }
            break;
            // addition for tonight
            case 't':
            {
                temp_time.tm_hour = 21;
            }
            break;
        }
    }
    else if($<number>1== 'm') $<number>$ = 0;

    temp_time.tm_min = temp_time.tm_min >=0 ? temp_time.tm_min : 0;
    temp_time.tm_sec = temp_time.tm_sec >=0 ? temp_time.tm_sec : 0;
    changeAmount[8] = $<number>1;
}

;

whenTime :                                                  /****** ex. "3:00" or "3pm" or "1830" ****/
MILITARYTIME
{
    char *timeparts = strtok($<string>1, ":");
    temp_time.tm_hour= atoi(timeparts);
    timeparts = strtok (NULL, ":");
    temp_time.tm_min= atoi(timeparts);
    temp_time.tm_sec = 0;
}
|
WHENTIME     {

        char *timeparts = strtok($<string>1, ":");
        temp_time.tm_hour= atoi(timeparts);
        temp_time.tm_min = 0;
        temp_time.tm_sec = 0;
        timeparts = strtok (NULL, ":");
        while (timeparts != NULL)
        {
            if(timeparts[0]=='a')
            {
                if(temp_time.tm_hour == 12)
                    temp_time.tm_hour = 0;
            }
            else if(timeparts[0]=='p')
            {
                if(temp_time.tm_hour < 12)
                    temp_time.tm_hour += 12;
            }
            else
            {
                temp_time.tm_min = atoi(timeparts);
            }
            timeparts = strtok (NULL, ":");
        }
}

;

%%

void yyerror(char *s) {
//    NSLog(@"error");
    fprintf(stderr, "%s\n", s);
}
