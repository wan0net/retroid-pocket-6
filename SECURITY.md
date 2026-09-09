# Security policy

Please report vulnerabilities privately using GitHub's **Report a
vulnerability** feature if it is enabled for this repository. Otherwise contact
the repository owner through their GitHub profile without publishing secrets or
device identifiers in an issue.

The scripts intentionally stop unless exactly one authorised ADB device matches
the committed RP6 identity policy. `ALLOW_UNVERIFIED_DEVICE=1` is an explicit
break-glass override; inspect the connected device before using it.

Downloaded Obtainium bootstrap APKs come from the upstream GitHub release and
are checked against the adjacent upstream SHA-256 file. Obtainium-managed apps
should be reviewed before installation; upstream compromise remains part of the
supply-chain threat model.
