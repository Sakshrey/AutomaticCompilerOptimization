#include <stdio.h>
#include <string.h>
#include "dead_code_elimination.h"

int isOverwrittenBeforeUse(int index, char variable[])
{
    for(int i = index + 1; i < irCount; i++)
    {
        if(strcmp(ir[i].result, variable) == 0)
        {
            return 1;
        }

        if(strcmp(ir[i].arg1, variable) == 0 ||
           strcmp(ir[i].arg2, variable) == 0)
        {
            return 0;
        }
    }

    return 0;
}

void deadCodeElimination()
{
    for(int i = 0; i < irCount - 1; i++)
    {
        if(strcmp(ir[i].op, "=") == 0)
        {
            if(isOverwrittenBeforeUse(i, ir[i].result))
            {
                for(int j = i; j < irCount - 1; j++)
                {
                    ir[j] = ir[j + 1];
                }

                irCount--;
                i--;
            }
        }
    }
}