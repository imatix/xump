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
    This class enables the creation of store extensions.  Store extensions
    are synchronous classes that implement the request methods defined here.
    Store extensions may be internally multithreaded but that is invisible
    to the calling application.
</doc>

<inherit class = "ipr_portal">
    <option name = "front_end" value = "sync" />
    <option name = "back_end" value = "sync" />
</inherit>

<import class = "xump_classes" />

<data>
    <request name = "store open">
      <doc>
        Opens a named store. If the store already exists, gives access to
        the resources that the store contains.  If necessary, creates a new
        store as named.  Returns a store handle.
      </doc>
      <field name = "name" type = "char *" />
    </request>

    <request name = "store close">
      <doc>
        Closes the store.  This does not destroy the store's resources.
        Following this method the store handle is no longer valid and may
        not be used.
      </doc>
      <field name = "store" type = "int" />
    </request>

    <request name = "queue open">
      <doc>
        Opens a named queue. If the queue already exists, gives access to
        the messges that the queue contains.  If necessary, creates a new
        queue as named.  Returns a queue handle.
      </doc>
      <field name = "store" type = "int" />
      <field name = "name" type = "char *" />
    </request>

    <request name = "queue destroy">
      <doc>
        Destroys the queue and any messages it contains.  Implies a queue
        close.  Following this method the queue handle is no longer valid.
      </doc>
      <field name = "queue" type = "int" />
    </request>

    <request name = "queue close">
      <doc>
        Closes the queue.  If the destroy argument is set, destroys all
        messages on the queue and then destroys the queue.  Otherwise, does
        not modify the queue.  Following this method the queue handle is no
        longer valid.
      </doc>
      <field name = "queue" type = "int" />
      <field name = "destroy" type = "Bool" />
    </request>

</data>

</class>
