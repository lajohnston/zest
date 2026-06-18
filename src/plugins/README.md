# Core Plugins

Plugins add additional functionality to the framework. They may hook into the test lifecycle hooks (`zest.preSuite`, `zest.preTest`, `zest.postTest`) to perform required initialisation and additional checks. They may expose additional macros for use in tests.

Zest implements some functionality as plugins in this directory as an example of how they can be used. The core framework is decoupled from them so they can be removed or replaced without breaking it.
