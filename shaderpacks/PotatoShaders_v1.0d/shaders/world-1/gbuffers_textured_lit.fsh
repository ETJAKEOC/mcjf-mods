#version 400 compatibility

/*
====================================================================================================

    Copyright (C) 2020 RRe36

    All Rights Reserved unless otherwise explicitly stated.


    By downloading this you have agreed to the license and terms of use.
    These can be found inside the included license-file
    or here: https://rre36.com/copyright-license

    Violating these terms may be penalized with actions according to the Digital Millennium
    Copyright Act (DMCA), the Information Society Directive and/or similar laws
    depending on your country.

====================================================================================================
*/

#define gTEXTURED
#define gNODIFF

#if MC_VERSION < 11500

#include "gbuffers_main.fsh"

#else

#define gTRANSLUCENT
#include "gbuffers_main.fsh"

#endif