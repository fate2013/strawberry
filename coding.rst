===============
Coding Standard
===============

.. contents:: Table Of Contents
.. section-numbering::

Overview
========

Don't make me think!


Dev Env
=======

- lua
  lua-5.3.2

- mysql

- redis
  redis-3.0.0

Encoding
========

lua file
########

utf-8 without BOM

db table
########

utf-8

request/response
################

utf-8

Lua
===

design
######

- scope and visibility

  variables and functions should be local

  采用“作用域小”优先原则

- prefer array mapping to switch clause

  too many cases is hard to read, but in array, they
  are straightforward.

- var declaration should be closest to its first reference

- lua files all has suffix of '.lua'

  never use like '.inc'

- class only talk to immediate friends
  
  never talk to strangers

- never copy extra variables

  especially when a var is referenced only once

  ::

    // bad
    local desc = ngx.req.get_uri_args()['description'];
    print(desc);

    // good
    print(ngx.req.get_uri_args()['description']);

format
######

- always add a space between the keyword and a operator

  ::

    a = a + 1; // good
    a = a+1;   // bad

- empty line

  - an empty line is reserved for seperation of different logical unit
    
    never overuse empty line

  - between method/function blocks
    
    there will be 1 and only 1 empty line

- indent

  4 spaces

  never use tab

- avoid line over 120 chars

- never use the following tags in file header
  @author

naming
######

- never include data type info in var name

  ::

    int_uid;    // never do like this
    uid;       // do like this

- private var && method all starts with '_'

- camel case names

  used for class name

  ::

    MysqlClient = {}

- lower case connected with underscore names

  used for file name, class name, function name

  ::

    mysql_client.lua
    function do_connect(host, port, timeout) {

- upper case connected with underscore names

  used for constants

  ::

    local DEFAULT_REPLICAS = 64

- do not reinvent an abbreviation unless it is really well known

comment
#######

It's a supplement for the statements, not a repitition.

- never comment out a code block without any comments.

- sync the logic with corresponding comments

  if the logic changes, change it's comment to

- keyword
  FIXME, TODO

- comments are placed directly above or directly right to the code block

- Chinese comments are encouraged

best practice
#############

- never use global variable

- never, ever trust players input

- always add a comma after an entry in array

  ::

    local rules = {
        uid = 12,  -- the ',' 
    }


Logging
=======

- if var name contained in log msg, it must absolutely match real var name

- will not end with period or other punctuations

- log msg/content begins with capital letter

- log msg/content can't be misleading

Commit
======

- frequent comits is encouraged

  Commit as soon as your changes makes a logical unit

- be precise and exhaustive in your commit comments

- test code before you commit

- git diff before you commit

Tools
=====

gnu global
##########

::

    http://www.gnu.org/software/global/global.html

ack 
###

::

    http://beyondgrep.com/

