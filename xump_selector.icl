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
    name    = "xump_selector"
    comment = "Xump selector class"
    script  = "icl_gen"
    license = "gpl"
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

<public name = "header">
//  Selector events
#define SELECTOR_WHEN_MATCH      1
#define SELECTOR_WHEN_FILTER     2
#define SELECTOR_WHEN_ALWAYS     3
#define SELECTOR_WHEN_OVERFLOW   4
#define SELECTOR_WHEN_DEFAULT    5

//  Selector actions
#define SELECTOR_DO_COPY         1
#define SELECTOR_DO_MOVE         2
#define SELECTOR_DO_DELIVER      3
#define SELECTOR_DO_BOUNCE       4
</public>

<context>
    uint
        id;
    char
        *source_queue,                  //  Queue where selector sits
        *target_queue,                  //  Optional target for messages
        *operator,                      //  Operator for event detection
        *argument,                      //  Argument for event detection
        *address;                       //  New address for action
    int
        event,                          //  When to invoke selector
        action;                         //  What to do when invoked
    Bool
        enabled;                        //  Active y/n?
    uint
        credits;                        //  Selector credits
</context>

<method name = "new">
    <argument name = "id" type = "uint" />
    <argument name = "source queue" type = "char *" />
    //
    self->id = id;
    self->source_queue = icl_mem_strdup (source_queue);
</method>

<method name = "destroy" private = "1">
    icl_mem_free (self->source_queue);
    icl_mem_free (self->target_queue);
    icl_mem_free (self->operator);
    icl_mem_free (self->argument);
    icl_mem_free (self->target_queue);
    icl_mem_free (self->address);
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
    self->event = SELECTOR_WHEN_MATCH;
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
    self->event = SELECTOR_WHEN_FILTER;
    self->operator = icl_mem_strdup (operator);
    self->argument = icl_mem_strdup (argument);
</method>

<method name = "when always" template = "function">
    <doc>
    Specifies that the selector is invoked on every message that enters the
    queue. May not be mixed with other 'when' methods.
    </doc>
    //
    if (self->event) {
        icl_console_print ("E: cannot register multiple events for selector");
        assert (!self->event);
    }
    self->event = SELECTOR_WHEN_ALWAYS;
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
    self->event = SELECTOR_WHEN_OVERFLOW;
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
    self->event = SELECTOR_WHEN_DEFAULT;
</method>

<method name = "do copy" template = "function">
    <doc>
    When the selector is invoked, it will copy the message to the specified
    queue.
    </doc>
    <argument name = "target queue" type = "char *" />
    //
    if (self->action) {
        icl_console_print ("E: cannot register multiple actions for selector");
        assert (!self->action);
    }
    self->action = SELECTOR_DO_COPY;
    self->target_queue = icl_mem_strdup (target_queue);
</method>

<method name = "do move" template = "function">
    <doc>
    When the selector is invoked, it will move the message to the specified
    queue.
    </doc>
    <argument name = "target queue" type = "char *" />
    //
    if (self->action) {
        icl_console_print ("E: cannot register multiple actions for selector");
        assert (!self->action);
    }
    self->action = SELECTOR_DO_MOVE;
    self->target_queue = icl_mem_strdup (target_queue);
</method>

<method name = "do deliver" template = "function">
    <doc>
    When the selector is invoked, it will move the message to the specified
    queue, setting the message address to the new value specified.
    </doc>
    <argument name = "target queue" type = "char *" />
    <argument name = "address" type = "char *" />
    //
    if (self->action) {
        icl_console_print ("E: cannot register multiple actions for selector");
        assert (!self->action);
    }
    self->action = SELECTOR_DO_DELIVER;
    self->target_queue = icl_mem_strdup (target_queue);
    self->address = icl_mem_strdup (address);
</method>

<method name = "do bounce" template = "function">
    <doc>
    When the selector is invoked, it will move the message to the specified
    queue, setting the message address to the message return address, if any.
    </doc>
    <argument name = "target queue" type = "char *" />
    //
    if (self->action) {
        icl_console_print ("E: cannot register multiple actions for selector");
        assert (!self->action);
    }
    self->action = SELECTOR_DO_BOUNCE;
    self->target_queue = icl_mem_strdup (target_queue);
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
    Adds a specified number of credits to the selector.  When the selector
    has
    </doc>
    <argument name = "credits" type = "uint" />
    //
    self->credits += credits;
</method>

<method name = "selftest" />

</class>
