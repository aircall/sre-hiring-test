# Common

These are shared terraform resources like variables and locals.

The makefile copies them into each stack before, doing the plan/apply.

If you're adding new files into the common directory, please also update the `Makefile` to include them.
