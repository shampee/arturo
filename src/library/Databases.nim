######################################################
# Arturo
# Programming Language + Bytecode VM compiler
# (c) 2019-2021 Yanis Zafirópulos
#
# @file: library/Databases.nim
######################################################

#=======================================
# Pragmas
#=======================================

{.used.}

#=======================================
# Libraries
#=======================================

import sequtils

when not defined(NOSQLITE):
    import helpers/database as DatabaseHelper

import vm/lib
import vm/[globals]

#=======================================
# Methods
#=======================================

# TODO(Databases) Add support for MySQL
#  Currently, the only supported database is Sqlite
#  labels: library,enhancement

# TODO(Databases) Add support for MongoDB
#  Currently, the only supported database is Sqlite
#  labels: library,enhancement

proc defineSymbols*() =

    when defined(VERBOSE):
        echo "- Importing: Databases"

    when not defined(NOSQLITE):

        builtin "close",
            alias       = unaliased, 
            rule        = PrefixPrecedence,
            description = "close given database",
            args        = {
                "database"  : {Database}
            },
            attrs       = NoAttrs,
            returns     = {Nothing},
            example     = """
            """:
                ##########################################################
                if x.dbKind == SqliteDatabase:
                    closeSqliteDb(x.sqlitedb)
                # elif x.dbKind == MysqlDatabase:
                #     closeMysqlDb(x.mysqldb)

        builtin "query",
            alias       = unaliased, 
            rule        = PrefixPrecedence,
            description = "execute command or block of commands in given database and get returned rows",
            args        = {
                "database"  : {Database},
                "commands"  : {String,Block}
            },
            attrs       = {
                "id"    : ({Boolean},"return last INSERT id")
            },
            returns     = {Integer,Block,Null},
            example     = """
            """:
                ##########################################################
                if x.dbKind == SqliteDatabase:
                    if y.kind == String:
                        if (let got = execSqliteDb(x.sqlitedb, y.s); got[0]==ValidQueryResult):
                            push(newBlock(got[1]))
                    else:
                        if (let got = execManySqliteDb(x.sqlitedb, y.a.map(proc (v:Value):string = v.s)); got[0]==ValidQueryResult):
                            push(newBlock(got[1]))
                    
                    if (popAttr("id") != VNULL):
                        push(newInteger(getLastIdSqliteDb(x.sqlitedb)))

                # elif x.dbKind == MysqlDatabase:
                #     execMysqlDb(x.mysqldb, y.s)

        builtin "open",
            alias       = unaliased, 
            rule        = PrefixPrecedence,
            description = "opens a new database connection and returns database",
            args        = {
                "name"  : {String}
            },
            attrs       = {
                "sqlite": ({Boolean},"support for SQLite databases"),
                "mysql" : ({Boolean},"support for MySQL databases")
            },
            returns     = {Database},
            example     = """
                db: open "my.db"    ; opens an SQLite database named 'my.db'
            """:
                ##########################################################
                var dbKind = SqliteDatabase

                if (popAttr("mysql") != VNULL):
                    dbKind = MysqlDatabase

                let dbName = x.s

                if dbKind == SqliteDatabase:
                    push(newDatabase(openSqliteDb(dbName)))
                # elif dbKind == MysqlDatabase:
                #     push(newDatabase(openMysqlDb(dbName)))

#=======================================
# Add Library
#=======================================

Libraries.add(defineSymbols)