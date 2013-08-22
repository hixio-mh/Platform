Adefy Cloud [ http://cloud.adefy.eu ]
=====================================

Cloud interface and customer backend for Adefy. This repo contains the site as
a whole, but pulls in dependencies from a few others. The backend will allow for

* New user registration
* User account management
* Campaign creation
* Campagin overview/statistics and settings
* Ad editing and management

The ad editor will be broken out into a seperate repo.

Details of operation
--------------------
Since the site is of relative complexity (compared to other projects such as
the SME) and utilizes patterns and components we've developed since February
2013, a brief introduction is necessary. The site runs with nodejs, using
Express as a server and Mongodb for db storage.

All of the relatively low-level things are wrapped by our Line library, which
is a public repo (unlike this code). Line provides a highly opinionated
interface to mongodb, and a structure for declarying express routes and socket
handlers. Line essentially bootstraps the server, by providing a reliable
interface for modules to declare their functionality at startup. This means that
socket listeners and routes are static once declared, but this should for the
most part not be an issue. Handlers can also be declared dynamically, albeit
less intuitively than if one was using Line.

Architecture
------------
The site is broken up into "modules", which are loaded up by C9's architect
module. Architect reads in the module list at startup, and handles dependency
resolution and all that jazz. The modules are read in order, beginning with
line, then our core-init-start bootstrapper. All of the general modules follow,
after which comes core-init-end to finish bootstrapping and launch the site
proper. To present a list:

Loaded in order,
* Line
* Core-init-start
* General modules
* Core-init-end

Building
--------
Gruntfiles! To be continued.