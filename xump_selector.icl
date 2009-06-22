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
    name      = "xump_selector"
    comment   = "Xump selector class"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The xump_selector class references a selector resource held in a storage
layer. Note: probably needs addition of headers object for header based
routing.
</doc>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
    <option name = "links" value = "1" />
</inherit>

<import class = "xump" />

<private name = "header">
//  Selector events
#define WHEN_MATCH      1
#define WHEN_FILTER     2
#define WHEN_ENTRY      3
#define WHEN_OVERFLOW   4
#define WHEN_DEFAULT    5

//  Selector actions
#define DO_COPY         1
#define DO_MOVE         2
#define DO_DELIVER      3
#define DO_BOUNCE       4
</private>

<context readonly = "1">
    int
        event,                          //  When to invoke selector
        action;                         //  What to do when invoked
    char
        *operator,                      //  Operator for event detection
        *argument,                      //  Argument for event detection
        *target;                        //  Named target for action
    Bool
        enabled;                        //  Active y/n?
    uint
        credits;                        //  Selector credits
    <property name = "id" type = "uint" />
    <property name = "queue name" type = "char *" />
</context>

<method name = "new">
    <argument name = "queue name" type = "char *" />
    <argument name = "id" type = "uint" />
    //
    self->id = id;
    self->queue_name = icl_mem_strdup (queue_name);
</method>

<method name = "destroy" private = "1">
    icl_mem_free (self->queue_name);
    icl_mem_free (self->operator);
    icl_mem_free (self->argument);
    icl_mem_free (self->target);
</method>

<method name = "when match" template = "function">
    <doc>
    Specifies match criteria for the event.  The selector will be invoked
    when the message matches the specified argument, using the specified
    match operator. May not be mixed with other 'when' methods.
    </doc>
    <argument name = "operator" type = "char *">Extensible operator</argument>
    <argument name = "argument" type = "char *">Requested match pattern</argument>
    //
    if (self->event) {
        icl_console_print ("E: cannot register multiple events for selector");
        assert (!self->event);
    }
    self->event = WHEN_MATCH;
    self->operator = icl_mem_strdup (operator);
    self->argument = icl_mem_strdup (argument);
</method>

<method name = "when filter" template = "function">
    <doc>
    Specifies filter criteria for the event.  The selector will be invoked
    when the message matches the specified filter operator and argument. May
    not be mixed with other 'when' methods.
    </doc>
    <argument name = "operator" type = "char *">Extensible operator</argument>
    <argument name = "argument" type = "char *">Requested match pattern</argument>
    //
    if (self->event) {
        icl_console_print ("E: cannot register multiple events for selector");
        assert (!self->event);
    }
    self->event = WHEN_FILTER;
    self->operator = icl_mem_strdup (operator);
    self->argument = icl_mem_strdup (argument);
</method>

<method name = "when entry" template = "function">
    <doc>
    Specifies that the selector is invoked on every message that enters the
    queue. May not be mixed with other 'when' methods.
    </doc>
    //
    if (self->event) {
        icl_console_print ("E: cannot register multiple events for selector");
        assert (!self->event);
    }
    self->event = WHEN_ENTRY;
</method>

<method name = "when overflow" template = "function">
    <doc>
    Specifies that the selector is invoked on every message that enters the
    queue when the queue is full. May not be mixed with other 'when' methods.
    </doc>
    //
    if (self->event) {
        icl_console_print ("E: cannot register multiple events for selector");
        assert (!self->event);
    }
    self->event = WHEN_OVERFLOW;
</method>

<method name = "when default" template = "function">
    <doc>
    Specifies that the selector is invoked on every message that cannot be
    processed by any other selector queue. May not be mixed with other 'when'
    methods.
    </doc>
    //
    if (self->event) {
        icl_console_print ("E: cannot register multiple events for selector");
        assert (!self->event);
    }
    self->event = WHEN_DEFAULT;
</method>

<method name = "do copy" template = "function">
    <doc>
    Specifies the selector action 'copy message to another queue'.
    </doc>
    <argument name = "queue name" type = "char *" />
    //
    if (self->action) {
        icl_console_print ("E: cannot register multiple actions for selector");
        assert (!self->action);
    }
    self->action = DO_COPY;
    self->target = icl_mem_strdup (queue_name);
</method>

<method name = "do move" template = "function">
    <doc>
    Specifies the selector action 'move to another queue'
    </doc>
    <argument name = "queue name" type = "char *" />
    //
    if (self->action) {
        icl_console_print ("E: cannot register multiple actions for selector");
        assert (!self->action);
    }
    self->action = DO_MOVE;
    self->target = icl_mem_strdup (queue_name);
</method>

<method name = "do deliver" template = "function">
    <doc>
    Specifies the selector action 'deliver to a named destination in the
    calling application'
    </doc>
    <argument name = "destination" type = "char *" />
    //
    if (self->action) {
        icl_console_print ("E: cannot register multiple actions for selector");
        assert (!self->action);
    }
    self->action = DO_DELIVER;
    self->target = icl_mem_strdup (destination);
</method>

<method name = "do bounce" template = "function">
    <doc>
    Specifies the selector action 'bounce to another queue, mangling the
    address and return address'.
    </doc>
    <argument name = "queue name" type = "char *" />
    //
    if (self->action) {
        icl_console_print ("E: cannot register multiple actions for selector");
        assert (!self->action);
    }
    self->action = DO_BOUNCE;
    self->target = icl_mem_strdup (queue_name);
</method>

<method name = "enable" template = "function">
    <doc>
    Enables or disables the selector.  New selectors are disabled and the
    caller must use this method at least once with a TRUE on_off argument
    to active them.
    </doc>
    <argument name = "on off" type = "Bool" />
    //
    self->enabled = on_off;
</method>

<method name = "credit" template = "function">
    <doc>
    Adds a specified number of credits to the selector.
    </doc>
    <argument name = "credits" type = "uint" />
    //
    self->credits += credits;
</method>

<method name = "selftest" />

</class>
