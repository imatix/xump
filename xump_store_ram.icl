<?xml?>
<!--
    Copyright (c) 1996-2009 iMatix Corporation

    This file is licensed under the GPL as follows:

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at
    your option) any later version.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    For information on alternative licensing for OEMs, please contact
    iMatix Corporation.
 -->
<class
    name      = "xump_store_ram"
    comment   = "Xump RAM store back-end"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
This class implements a RAM-based storage layer.  Queues and messages are
local to the Xump engine instance and are destroyed when the engine or the
portal to this back-end are destroyed.
</doc>

<inherit class = "xump_store_back" />

<context>
</context>

<method name = "announce">
    icl_console_print ("I: initializing RAM-based storage instance '%s'", portal->name);
</method>

</class>
