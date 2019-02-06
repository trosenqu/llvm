//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <random>

// template<class IntType = int>
// class discrete_distribution
// {
//     class param_type;

#include <random>
#include <type_traits>

int main()
{
    {
        typedef std::discrete_distribution<> D;
        typedef D::param_type param_type;
        typedef param_type::distribution_type distribution_type;
        static_assert((std::is_same<D, distribution_type>::value), "");
    }
}
