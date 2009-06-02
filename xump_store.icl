<?xml?>
<!--
    Copyright (c) 1996-2009 iMatix Corporation

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
    name    = "xump_store"
    comment = "Xump store portal"
    script  = "icl_gen"
    >
<doc>
    This class enables the creation of store back-ends.  Store back-ends
    are synchronous classes that implement the request methods defined here.
    Store extensions may be internally multithreaded (i.e. pass requests to
    internally asynchronous objects) but that is invisible to the calling
    application.
</doc>

<inherit class = "ipr_portal">
    <option name = "front_end" value = "sync" />
    <option name = "back_end" value = "sync" />
</inherit>

<import class = "asl" />

<context>
    icl_shortstr_t
        name;                           //  Store name
</context>

<data>
    <request name = "announce" />
</data>

<method name = "new">
    <argument name = "name" type = "char *" />
    icl_shortstr_cpy (self->name, name);
</method>

</class>
