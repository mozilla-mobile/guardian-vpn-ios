// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

#ifndef Guardian_Bridging_Header_h
#define Guardian_Bridging_Header_h

#include "x25519.h"
#include "wireguard-go-version.h"
#include "ringlogger.h"
#include "key.h"

#import "TargetConditionals.h"
#if TARGET_OS_OSX
#include <libproc.h>
#endif

#endif /* Guardian_Bridging_Header_h */
