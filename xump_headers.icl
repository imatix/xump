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
    name      = "xump_headers"
    comment   = "Xump headers class"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The xump_headers class implements a environ-style headers block.
</doc>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
    <option name = "links" value = "1" />
</inherit>

<import class = "xump" />

<context>
    icl_longstr_t
        *longstr;                       //  Data for headers table
</context>

<method name = "new">
    //  Constructor is deliberately empty
</method>

<method name = "destroy">
    icl_longstr_destroy (&self->longstr);
</method>

<method name = "set" template = "function">
    <doc>
    Sets a header value.
    </doc>
    <argument name = "name"  type = "char *" />
    <argument name = "value" type = "char *" />
    //
    //  Name may not contain '=', that's a fail
    assert (strchr (name, '=') == NULL);
    if (self->longstr) {
        //  Look for existing value, squash if any
        icl_shortstr_t
            name_key;
        char
            *found;

        icl_shortstr_fmt (name_key, "%s=", name);
        found = (char *) icl_longstr_find (
            self->longstr, 0, (byte *) name_key, strlen (name_key));
        if (found) {
            byte
                *next = (byte *) strchr (found, 0) + 1;
            self->longstr->cur_size -= (next - self->longstr->data);
            memcpy (found, next, self->longstr->cur_size);
        }
        //  String ends in double null, we'll quash the last one
        if (self->longstr->cur_size)
            self->longstr->cur_size--;
    }
    else
        self->longstr = icl_longstr_new (NULL, 1024);

    icl_longstr_cat (self->longstr, "%s=%s%c%c", name, value, 0, 0);
</method>

<method name = "get" return = "value">
    <doc>
    Returns value of specified header; if not found returns an empty string.
    </doc>
    <argument name = "self" type = "$(selftype) *" />
    <argument name = "name" type = "char *" />
    <declare name = "value" type = "char *" />
    value = "";                         //  Default is empty string
    if (self->longstr) {
        icl_shortstr_t
            name_key;
        char
            *found;

        icl_shortstr_fmt (name_key, "%s=", name);
        found = (char *) icl_longstr_find (
            self->longstr, 0, (byte *) name_key, strlen (name_key));
        if (found)
            value = found + strlen (name_key);
    }
</method>

<method name = "selftest">
    xump_headers_t
        *headers;

    headers = xump_headers_new ();
    xump_headers_set (headers, "a", "one");
    xump_headers_set (headers, "b", "two");
    xump_headers_set (headers, "c", "three");
    xump_headers_set (headers, "a", "value");
    assert (streq (xump_headers_get (headers, "a"), "value"));
    assert (streq (xump_headers_get (headers, "z"), ""));
    xump_headers_destroy (&headers);
</method>

</class>
