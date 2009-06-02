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
    name      = "xump_message"
    comment   = "Xump message class"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The xump_message class holds contents and property fields.
The current implementation stores messages in memory only.
Messages are either physical (they have data) or virtual
(they refer to a physical message).  Applications work with
virtual messages only.  This class creates and destroys the
physical messages automatically, behind the scenes.
</doc>

<inherit class = "icl_object">
    <option name = "alloc"  value = "cache" />
    <option name = "links"  value = "1" />
    <option name = "rwlock" value = "1" />
</inherit>

<import class = "asl" />

<private name = "header">
#define XUMP_MESSAGE_PHYSICAL   (void *) (-1)
</private>

<context>
    address
    body
    size
    fields

Every single message has an address, which is used heavily, so we will make this a dedicated property of the class.  A message also has content body, content length, and a table of name/value fields.


    //  Context for a physical message
    ipr_dict_table_t
        *fields;                        //  Envelope field table
    ipr_looseref_list_t
        *contents;                      //  List of typed contents

    //  Context for a virtual message
    xump_message_t
        *physical;                      //  Physical message
</context>

<method name = "new">
    <doc>
    Creates a new virtual message.  If the message argument is null,
    implicitly creates a new physical message as well.  If the message
    argument is not null, the new virtual message links to the same
    physical message as the specified one.
    For internal use: pass XUMP_MESSAGE_PHYSICAL to create a new
    physical message.
    </doc>
    <argument name = "message" type = "xump_message_t *">Message to clone</argument>
    //
    if (message == XUMP_MESSAGE_PHYSICAL)
        ;                               //  Create physical message
    else
    if (message) {
        assert (message->physical);
        self->physical = xump_message_link (message->physical);
    }
    else
        self->physical = xump_message_new (XUMP_MESSAGE_PHYSICAL);
</method>

<method name = "destroy">
    //  Destroy context for physical message
    ipr_dict_table_destroy (&self->fields);

    //  Destroy context for virtual message
    xump_message_unlink (&self->physical);
</method>

<method name = "field set" template = "function">
    <doc>
    Sets an envelope field value.  Accepts a printf-style format specifier
    with a variable argument list.  The formatted string is restricted to
    some arbitrary value.  All user supplied strings should be provided as
    arguments, not as format.
    </doc>
    <argument name = "name" type = "char *">Field name</argument>
    <argument name = "format" type = "char *">Format specifier</argument>
    <argument name = "args" type = "...">Variable arguments</argument>
    <local>
    icl_shortstr_t
        value;
    </local>
    //
    //  If virtual message, resolve format string and pass on to
    //  physical message.  If physical message, store into table.
    if (self->physical) {
        apr_vsnprintf (value, ICL_SHORTSTR_MAX, format, args);
        self_field_set (self->physical, name, value);
    }
    else {
        if (self->fields == NULL)
            self->fields = ipr_dict_table_new ();
        ipr_dict_assume (self->fields, name, format);
    }
</method>

<method name = "field get" return = "value">
    <doc>
    Retrieves an envelope field and returns its string value.  Returns
    "" if the field was not set.  Field names are case-sensitive.
    The value is copied into a new memory buffer that the caller must
    free when the value is no longer needed.
    </doc>
    <argument name = "self" type = "$(selftype) *">Self</argument>
    <argument name = "name" type = "char *">Field name</argument>
    <declare name = "value" type = "char *" />
    <local>
    ipr_dict_t
        *item;
    </local>
    //
    //  The fields table is created opportunistically, so may be null
    //  If virtual message, pass on to physical message.  If physical
    //  message, get from table.
    if (self->physical)
        value = self_field_get (self->physical, name);
    else {
        value = "";
        if (self->fields) {
            item = ipr_dict_table_search (self->fields, name);
            if (item)
                value = item->value;
        }
        value = icl_mem_strdup (value);
    }
</method>

<method name = "selftest">
    <local>
    xump_message_t
        *message1,
        *message2;
    char
        *value;
    </local>
    //
    //  Create two virtual messages that map to the same physical message
    message1 = xump_message_new (NULL);
    message2 = xump_message_new (message1);

    //  Check that an undefined property is empty
    value = xump_message_field_get (message1, "code");
    assert (streq (value, ""));
    icl_mem_free (value);

    //  Check that a property set in one virtual message show in the other
    xump_message_field_set (message1, "code", "1234");
    value = xump_message_field_get (message1, "code");
    assert (streq (value, "1234"));
    icl_mem_free (value);
    value = xump_message_field_get (message2, "code");
    assert (streq (value, "1234"));
    icl_mem_free (value);

    //  Destroy the two virtual messages, the physical one should also go
    xump_message_destroy (&message1);
    xump_message_destroy (&message2);
</method>

</class>
