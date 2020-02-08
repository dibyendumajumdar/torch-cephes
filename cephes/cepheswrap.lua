-- Utility to generate Lua C api based
-- interface for torch.nn
-- Note that the wrap() calls were generated
-- using the tools/extract.lua utility
-- Some aspects of the interface needed changes
-- a) optional args handling - we use nil as optional indicator
-- b) IndexTensor args need noreadadd set to true to aoid adding -1
-- c) Index_t is mapped to int64_t rather than index as latter does adjustment by 1 that
--    breaks PReLU - need to check why Torch does this adjustment elsewhere but
--    here it causes problems

local wrap = require 'cwrap'

local interface = wrap.CInterface.new()
local argtypes = wrap.CInterface.argtypes

argtypes['ptrdiff_t'] = wrap.types.ptrdiff_t

local function interpretdefaultvalue(arg)
   local default = arg.default
   if type(default) == 'boolean' then
      if default then
         return '1'
      else
         return '0'
      end
   elseif type(default) == 'number' then
      return tostring(default)
   elseif type(default) == 'string' then
      return default
   elseif type(default) == 'function' then
      default = default(arg)
      assert(type(default) == 'string', 'a default function must return a string')
      return default
   elseif type(default) == 'nil' then
      return nil
   else
      error('unknown default type value')
   end   
end
argtypes.index = argtypes['int64_t']

interface:print([[
#ifdef __cplusplus
# define CEPHES_EXTERNC extern "C"
#else
# define CEPHES_EXTERNC extern
#endif

#ifdef _WIN32
# ifdef CEPHES_EXPORTS
#  define CEPHES_API CEPHES_EXTERNC __declspec(dllexport)
# else
#  define CEPHES_API CEPHES_EXTERNC __declspec(dllimport)
# endif
#else
# define CEPHES_API CEPHES_EXTERNC
#endif

#ifdef __cplusplus
extern "C" {
#endif
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <luaT.h>

CEPHES_API int luaopen_tcephes(lua_State *L);

#ifdef __cplusplus
}
#endif

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "mconf.h"
]])

interface:print('/* WARNING: autogenerated file */')
interface:print('')

local function wrap(...)
   local args = {...}
   -- interface
   interface:wrap(...)
end

wrap("torch_cephes_geterr", "torch_cephes_geterr", {{name="int", creturned=true}})
wrap("torch_cephes_seterr", "torch_cephes_seterr", {{name="int"}})
--[[
wrap("torch_cephes_acosh", "torch_cephes_acosh", {{name="double"},{name="double", creturned=true}})
wrap("torch_cephes_bdtrc", "torch_cephes_bdtrc", {{name="int"}, {name="int"}, {name="double"}, {name="double", creturned=true}})
wrap("torch_cephes_bdtr", "torch_cephes_bdtr", {{name="int"}, {name="int"}, {name="double"}, {name="double", creturned=true}})
wrap("torch_cephes_bdtri", "torch_cephes_bdtri", {{name="int"}, {name="int"}, {name="double"}, {name="double", creturned=true}})
wrap("torch_cephes_btdtr", "torch_cephes_btdtr", {{name="double"}, {name="double"}, {name="double"}, {name="double", creturned=true}})
wrap("torch_cephes_chdtrc", "torch_cephes_chdtrc", {{name="double"}, {name="double"}, {name="double", creturned=true}})
wrap("torch_cephes_chdtr", "torch_cephes_chdtr", {{name="double"}, {name="double"}, {name="double", creturned=true}})
wrap("torch_cephes_chdtri", "torch_cephes_chdtri", {{name="double"}, {name="double"}, {name="double", creturned=true}})
-- drand
wrap("torch_cephes_expx2", "torch_cephes_expx2", {{name="double"}, {name="int"}, {name="double", creturned=true}})
]]

local functions_list = {
    { name = 'bdtrc', arguments = { { name = 'k', type = 'int' }, { name = 'n', type = 'int' }, { name = 'p', type = 'double' } }, returnType = 'double' },
    { name = 'bdtr', arguments = { { name = 'k', type = 'int' }, { name = 'n', type = 'int' }, { name = 'p', type = 'double' } }, returnType = 'double' },
    { name = 'bdtri', arguments = { { name = 'k', type = 'int' }, { name = 'n', type = 'int' }, { name = 'y', type = 'double' } }, returnType = 'double' },
    { name = 'btdtr', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'chdtrc', arguments = { { name = 'df', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'chdtr', arguments = { { name = 'df', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'chdtri', arguments = { { name = 'df', type = 'double' }, { name = 'y', type = 'double' } }, returnType = 'double' },
    { name = 'drand', arguments = { { name = 'a', type = 'double *' } }, returnType = 'int' },
    { name = 'expx2', arguments = { { name = 'x', type = 'double' }, { name = 'sign', type = 'int' } }, returnType = 'double' },
    { name = 'fdtrc', arguments = { { name = 'ia', type = 'int' }, { name = 'ib', type = 'int' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'fdtr', arguments = { { name = 'ia', type = 'int' }, { name = 'ib', type = 'int' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'fdtri', arguments = { { name = 'ia', type = 'int' }, { name = 'ib', type = 'int' }, { name = 'y', type = 'double' } }, returnType = 'double' },
    { name = 'gamma', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'lgam', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'gdtr', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'gdtrc', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'igamc', arguments = { { name = 'a', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'igam', arguments = { { name = 'a', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'igami', arguments = { { name = 'a', type = 'double' }, { name = 'y0', type = 'double' } }, returnType = 'double' },
    { name = 'incbet', arguments = { { name = 'aa', type = 'double' }, { name = 'bb', type = 'double' }, { name = 'xx', type = 'double' } }, returnType = 'double' },
    { name = 'incbi', arguments = { { name = 'aa', type = 'double' }, { name = 'bb', type = 'double' }, { name = 'yy0', type = 'double' } }, returnType = 'double' },
    { name = 'nbdtrc', arguments = { { name = 'k', type = 'int' }, { name = 'n', type = 'int' }, { name = 'p', type = 'double' } }, returnType = 'double' },
    { name = 'nbdtr', arguments = { { name = 'k', type = 'int' }, { name = 'n', type = 'int' }, { name = 'p', type = 'double' } }, returnType = 'double' },
    { name = 'nbdtri', arguments = { { name = 'k', type = 'int' }, { name = 'n', type = 'int' }, { name = 'p', type = 'double' } }, returnType = 'double' },
    { name = 'ndtr', arguments = { { name = 'a', type = 'double' } }, returnType = 'double' },
    { name = 'erfc', arguments = { { name = 'a', type = 'double' } }, returnType = 'double' },
    { name = 'erf', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'ndtri', arguments = { { name = 'y0', type = 'double' } }, returnType = 'double' },
    { name = 'pdtrc', arguments = { { name = 'k', type = 'int' }, { name = 'm', type = 'double' } }, returnType = 'double' },
    { name = 'pdtr', arguments = { { name = 'k', type = 'int' }, { name = 'm', type = 'double' } }, returnType = 'double' },
    { name = 'pdtri', arguments = { { name = 'k', type = 'int' }, { name = 'y', type = 'double' } }, returnType = 'double' },
    { name = 'polevl', arguments = { { name = 'x', type = 'double' }, { name = 'coef[]', type = 'double' }, { name = 'N', type = 'int' } }, returnType = 'double' },
    { name = 'p1evl', arguments = { { name = 'x', type = 'double' }, { name = 'coef[]', type = 'double' }, { name = 'N', type = 'int' } }, returnType = 'double' },
    { name = 'stdtr', arguments = { { name = 'k', type = 'int' }, { name = 't', type = 'double' } }, returnType = 'double' },
    { name = 'stdtri', arguments = { { name = 'k', type = 'int' }, { name = 'p', type = 'double' } }, returnType = 'double' },
    { name = 'log1p', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'expm1', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'cosm1', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'beta', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' } }, returnType = 'double' },
    { name = 'lbeta', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' } }, returnType = 'double' },
    { name = 'chbevl', arguments = { { name = 'x', type = 'double' }, { name = 'array[]', type = 'double' }, { name = 'n', type = 'int' } }, returnType = 'double' },
    { name = 'dawsn', arguments = { { name = 'xx', type = 'double' } }, returnType = 'double' },
    { name = 'ei', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'expn', arguments = { { name = 'n', type = 'int' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'fac', arguments = { { name = 'i', type = 'int' } }, returnType = 'double' },
    { name = 'fresnl', arguments = { { name = 'xxa', type = 'double' }, { name = 'ssa', type = 'double *' }, { name = 'cca', type = 'double *' } }, returnType = 'int' },
    { name = 'polevl', arguments = { { name = 'x', type = 'double' }, { name = 'coef[]', type = 'double' }, { name = 'N', type = 'int' } }, returnType = 'double' },
    { name = 'p1evl', arguments = { { name = 'x', type = 'double' }, { name = 'coef[]', type = 'double' }, { name = 'N', type = 'int' } }, returnType = 'double' },
    { name = 'psi', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'revers', arguments = { { name = 'y[]', type = 'double' }, { name = 'x[]', type = 'double' }, { name = 'n', type = 'int' } }, returnType = 'void' },
    { name = 'rgamma', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'shichi', arguments = { { name = 'x', type = 'double' }, { name = 'si', type = 'double *' }, { name = 'ci', type = 'double *' } }, returnType = 'int' },
    { name = 'sici', arguments = { { name = 'x', type = 'double' }, { name = 'si', type = 'double *' }, { name = 'ci', type = 'double *' } }, returnType = 'int' },
    { name = 'simpsn', arguments = { { name = 'f[]', type = 'double' }, { name = 'delta', type = 'double' } }, returnType = 'double' },
    { name = 'spence', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'zeta', arguments = { { name = 'x', type = 'double' }, { name = 'q', type = 'double' } }, returnType = 'double' },
    { name = 'zetac', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'cadd', arguments = { { name = 'a', type = 'cmplx *' }, { name = 'b', type = 'cmplx *' }, { name = 'c', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'csub', arguments = { { name = 'a', type = 'cmplx *' }, { name = 'b', type = 'cmplx *' }, { name = 'c', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cmul', arguments = { { name = 'a', type = 'cmplx *' }, { name = 'b', type = 'cmplx *' }, { name = 'c', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cdiv', arguments = { { name = 'a', type = 'cmplx *' }, { name = 'b', type = 'cmplx *' }, { name = 'c', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cmov', arguments = { { name = 'a', type = 'void *' }, { name = 'b', type = 'void *' } }, returnType = 'void' },
    { name = 'cneg', arguments = { { name = 'a', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cabs', arguments = { { name = 'z', type = 'cmplx *' } }, returnType = 'double' },
    { name = 'csqrt', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'hypot', arguments = { { name = 'x', type = 'double' }, { name = 'y', type = 'double' } }, returnType = 'double' },
    { name = 'ellie', arguments = { { name = 'phi', type = 'double' }, { name = 'm', type = 'double' } }, returnType = 'double' },
    { name = 'ellik', arguments = { { name = 'phi', type = 'double' }, { name = 'm', type = 'double' } }, returnType = 'double' },
    { name = 'ellpe', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'ellpj', arguments = { { name = 'u', type = 'double' }, { name = 'm', type = 'double' }, { name = 'sn', type = 'double *' }, { name = 'cn', type = 'double *' }, { name = 'dn', type = 'double *' }, { name = 'ph', type = 'double *' } }, returnType = 'int' },
    { name = 'ellpk', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'polevl', arguments = { { name = 'x', type = 'double' }, { name = 'coef[]', type = 'double' }, { name = 'N', type = 'int' } }, returnType = 'double' },
    { name = 'p1evl', arguments = { { name = 'x', type = 'double' }, { name = 'coef[]', type = 'double' }, { name = 'N', type = 'int' } }, returnType = 'double' },
    { name = 'acosh', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'asin', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'acos', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'asinh', arguments = { { name = 'xx', type = 'double' } }, returnType = 'double' },
    { name = 'atan', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'atan2', arguments = { { name = 'y', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'atanh', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'cbrt', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'chbevl', arguments = { { name = 'x', type = 'double' }, { name = 'array[]', type = 'double' }, { name = 'n', type = 'int' } }, returnType = 'double' },
    { name = 'clog', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cexp', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'csin', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'ccos', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'ctan', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'ccot', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'casin', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cacos', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'catan', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cadd', arguments = { { name = 'a', type = 'cmplx *' }, { name = 'b', type = 'cmplx *' }, { name = 'c', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'csub', arguments = { { name = 'a', type = 'cmplx *' }, { name = 'b', type = 'cmplx *' }, { name = 'c', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cmul', arguments = { { name = 'a', type = 'cmplx *' }, { name = 'b', type = 'cmplx *' }, { name = 'c', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cdiv', arguments = { { name = 'a', type = 'cmplx *' }, { name = 'b', type = 'cmplx *' }, { name = 'c', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cmov', arguments = { { name = 'a', type = 'void *' }, { name = 'b', type = 'void *' } }, returnType = 'void' },
    { name = 'cneg', arguments = { { name = 'a', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cabs', arguments = { { name = 'z', type = 'cmplx *' } }, returnType = 'double' },
    { name = 'csqrt', arguments = { { name = 'z', type = 'cmplx *' }, { name = 'w', type = 'cmplx *' } }, returnType = 'void' },
    { name = 'cosh', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'drand', arguments = { { name = 'a', type = 'double *' } }, returnType = 'int' },
    { name = 'exp', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'exp10', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'exp2', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'fabs', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'ceil', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'floor', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'frexp', arguments = { { name = 'x', type = 'double' }, { name = 'pw2', type = 'int *' } }, returnType = 'double' },
    { name = 'ldexp', arguments = { { name = 'x', type = 'double' }, { name = 'pw2', type = 'int' } }, returnType = 'double' },
    { name = 'signbit', arguments = { { name = 'x', type = 'double' } }, returnType = 'int' },
    { name = 'isnan', arguments = { { name = 'x', type = 'double' } }, returnType = 'int' },
    { name = 'isfinite', arguments = { { name = 'x', type = 'double' } }, returnType = 'int' },
    { name = 'log', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'log10', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'log2', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'polevl', arguments = { { name = 'x', type = 'double' }, { name = 'coef[]', type = 'double' }, { name = 'N', type = 'int' } }, returnType = 'double' },
    { name = 'p1evl', arguments = { { name = 'x', type = 'double' }, { name = 'coef[]', type = 'double' }, { name = 'N', type = 'int' } }, returnType = 'double' },
    { name = 'pow', arguments = { { name = 'x', type = 'double' }, { name = 'y', type = 'double' } }, returnType = 'double' },
    { name = 'powi', arguments = { { name = 'x', type = 'double' }, { name = 'nn', type = 'int' } }, returnType = 'double' },
    { name = 'round', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'sin', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'cos', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'radian', arguments = { { name = 'd', type = 'double' }, { name = 'm', type = 'double' }, { name = 's', type = 'double' } }, returnType = 'double' },
    { name = 'sincos', arguments = { { name = 'x', type = 'double' }, { name = 's', type = 'double *' }, { name = 'c', type = 'double *' }, { name = 'flg', type = 'int' } }, returnType = 'int' },
    { name = 'sindg', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'cosdg', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'sinh', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'sqrt', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'tan', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'cot', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'tandg', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'cotdg', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'tanh', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'euclid', arguments = { { name = 'num', type = 'double *' }, { name = 'den', type = 'double *' } }, returnType = 'double' },
    { name = 'polrt', arguments = { { name = 'xcof[]', type = 'double' }, { name = 'cof[]', type = 'double' }, { name = 'm', type = 'int' }, { name = 'root[]', type = 'cmplx' } }, returnType = 'int' },
    { name = 'polini', arguments = { { name = 'maxdeg', type = 'int' } }, returnType = 'void' },
    { name = 'polprt', arguments = { { name = 'a[]', type = 'double' }, { name = 'na', type = 'int' }, { name = 'd', type = 'int' } }, returnType = 'void' },
    { name = 'polclr', arguments = { { name = 'a', type = 'double *' }, { name = 'n', type = 'int' } }, returnType = 'void' },
    { name = 'polmov', arguments = { { name = 'a', type = 'double *' }, { name = 'na', type = 'int' }, { name = 'b', type = 'double *' } }, returnType = 'void' },
    { name = 'polmul', arguments = { { name = 'a[]', type = 'double' }, { name = 'na', type = 'int' }, { name = 'b[]', type = 'double' }, { name = 'nb', type = 'int' }, { name = 'c[]', type = 'double' } }, returnType = 'void' },
    { name = 'poladd', arguments = { { name = 'a[]', type = 'double' }, { name = 'na', type = 'int' }, { name = 'b[]', type = 'double' }, { name = 'nb', type = 'int' }, { name = 'c[]', type = 'double' } }, returnType = 'void' },
    { name = 'polsub', arguments = { { name = 'a[]', type = 'double' }, { name = 'na', type = 'int' }, { name = 'b[]', type = 'double' }, { name = 'nb', type = 'int' }, { name = 'c[]', type = 'double' } }, returnType = 'void' },
    { name = 'poldiv', arguments = { { name = 'a[]', type = 'double' }, { name = 'na', type = 'int' }, { name = 'b[]', type = 'double' }, { name = 'nb', type = 'int' }, { name = 'c[]', type = 'double' } }, returnType = 'int' },
    { name = 'polsbt', arguments = { { name = 'a[]', type = 'double' }, { name = 'na', type = 'int' }, { name = 'b[]', type = 'double' }, { name = 'nb', type = 'int' }, { name = 'c[]', type = 'double' } }, returnType = 'void' },
    { name = 'poleva', arguments = { { name = 'a[]', type = 'double' }, { name = 'na', type = 'int' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'revers', arguments = { { name = 'y[]', type = 'double' }, { name = 'x[]', type = 'double' }, { name = 'n', type = 'int' } }, returnType = 'void' },
    { name = 'airy', arguments = { { name = 'x', type = 'double' }, { name = 'ai', type = 'double *' }, { name = 'aip', type = 'double *' }, { name = 'bi', type = 'double *' }, { name = 'bip', type = 'double *' } }, returnType = 'int' },
    { name = 'hyp2f1', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' }, { name = 'c', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'hyperg', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'hyp2f0', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' }, { name = 'x', type = 'double' }, { name = 'type', type = 'int' }, { name = 'err', type = 'double *' } }, returnType = 'double' },
    { name = 'i0', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'i0e', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'i1', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'i1e', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'iv', arguments = { { name = 'v', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'j0', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'y0', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'j1', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'y1', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'jn', arguments = { { name = 'n', type = 'int' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'jv', arguments = { { name = 'n', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'k0', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'k0e', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'k1', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'k1e', arguments = { { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'kn', arguments = { { name = 'nn', type = 'int' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'onef2', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' }, { name = 'c', type = 'double' }, { name = 'x', type = 'double' }, { name = 'err', type = 'double *' } }, returnType = 'double' },
    { name = 'threef0', arguments = { { name = 'a', type = 'double' }, { name = 'b', type = 'double' }, { name = 'c', type = 'double' }, { name = 'x', type = 'double' }, { name = 'err', type = 'double *' } }, returnType = 'double' },
    { name = 'struve', arguments = { { name = 'v', type = 'double' }, { name = 'x', type = 'double' } }, returnType = 'double' },
    { name = 'yn', arguments = { { name = 'n', type = 'int' }, { name = 'x', type = 'double' } }, returnType = 'double' },
}

for i = 1,#functions_list do
  local f = functions_list[i]
  local name = 'torch_cephes_' .. f.name
  local args = f.arguments
  local skip = false
  local outargs = {}
  for j = 1, #args do
    local arg = args[j]
    if (arg.type == 'int' or
      arg.type == 'double') 
      and not string.find(arg.name, '%[%]') then
    else
      skip = true
    end
    outargs[j] = { name=arg.type }
  end
  if not skip then
    if f.returnType == 'double' or f.returnType == 'int' then
      outargs[#outargs+1] = { name=f.returnType, creturned=true }
    end
    wrap(name, name, outargs)
  end
end

interface:register('cephes_funcs')

interface:print([[
int luaopen_tcephes(lua_State *L) {
  luaL_newlib(L, cephes_funcs);
  return 1;
}
]])

if arg[1] then
   interface:tofile(arg[1])
else
   print(interface:tostring())
end

