module NFloats

using Libdl
using FLINT_jll

macro libflint(function_name)
    return (:($function_name), FLINT_jll.libflint)
end



end  # NFloats
