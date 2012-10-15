# -*- coding: utf-8 -*-

'''
Convert DDL created by MySQL Workbench to suitable postgreSQL-DDL
Indices on PK clumns need to be deleted manually
Author  Bernhard Ströbl KIJ/DV
bernhard.stroebl@jena.de
Date begin: 03.03.2011
'''

import sys
import re
        
if __name__ == "__main__":
    if len(sys.argv) == 1: # first one is the executed file itself
        print "Usage mysql_2_pg \<sql file ohne Extension\>"
    else:    
        myFile = sys.argv[1] + ".sql"
        pgFile = myFile + ".pg" + ".sql"
        f = open(myFile, 'r')
        outF = open(pgFile, 'w')
        pgSql = ""
        for line in f:
            ddl = line
            if re.match("SET ", line):
                continue
            #if re.match("CREATE INDEX", line):
            #    continue
            if re.match("CREATE SCHEMA", line):
                continue
            if re.match("USE", line):
                continue    
            
            ddl = ddl.replace('`', '\"')
            ddl = ddl.replace('IF NOT EXISTS', '')
            ddl = ddl.replace('COMMIT;', '')
            ddl = ddl.replace(' INT ', ' INTEGER ')
            ddl = ddl.replace(' INT(11) ', ' INTEGER ')
            ddl = ddl.replace(' TINYINT(1) ', ' BOOLEAN ')
            ddl = ddl.replace(' DECIMAL ', ' REAL ')
            ddl = ddl.replace('ENGINE = InnoDB', '')
            ddl = ddl.replace(' ASC', '')
            ddl = ddl.replace('CREATE INDEX "', 'CREATE INDEX "idx_')
            outF.write(ddl)
        
        f.close()
        outF.close()
        
        
        
        print "finished"
    
