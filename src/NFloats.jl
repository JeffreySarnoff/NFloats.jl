module NFloats

using Libdl
using FLINT_jll

const libflint_filepath = FLINT_jll.libflint
if !isfile(libflint_filepath)
    throw(ErrorException("FLINT_jll not found")
end
    
const libflint_handle = Libdl.dlopen(libflint_filepath)

libfloat_fptr(sym) = dlsym(libflint_handle, sym)
    
macro libflint(function_name)
    return (:($function_name), FLINT_jll.libflint)
end



end  # NFloats
