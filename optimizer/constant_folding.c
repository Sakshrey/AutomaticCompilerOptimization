#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "constant_folding.h"

int isNumber(char str[])
{
    if(str[0] == '\0')
        return 0;

    for(int i = 0; str[i] != '\0'; i++)
    {
        if(str[i] < '0' || str[i] > '9')
            return 0;
    }

    return 1;
}

void constantFolding()
{
    for(int i = 0; i < irCount; i++)
    {
        if(strcmp(ir[i].op, "+") == 0 ||
           strcmp(ir[i].op, "-") == 0 ||
           strcmp(ir[i].op, "*") == 0 ||
           strcmp(ir[i].op, "/") == 0)
        {
            if(!isNumber(ir[i].arg1) || !isNumber(ir[i].arg2))
                continue;

            int a = atoi(ir[i].arg1);
            int b = atoi(ir[i].arg2);
            int result;

            if(strcmp(ir[i].op, "+") == 0)
                result = a + b;
            else if(strcmp(ir[i].op, "-") == 0)
                result = a - b;
            else if(strcmp(ir[i].op, "*") == 0)
                result = a * b;
            else
            {
                if(b == 0)
                    continue;

                result = a / b;
            }

            sprintf(ir[i].arg1, "%d", result);
            strcpy(ir[i].op, "");
            strcpy(ir[i].arg2, "");
        }
    }
}