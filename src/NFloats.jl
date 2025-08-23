module NFloats

using Libdl
using FLINT_jll

const libflint_filepath = FLINT_jll.libflint
if !isfile(libflint_filepath)
    throw(ErrorException("FLINT_jll not found"))
end
    
const libflint_handle = Libdl.dlopen(libflint_filepath)

libfloat_fptr(sym::Symbol) = dlsym(libflint_handle, sym)
    
macro libflint(function_name)
    return (:($function_name), libflint_handle)
end

# Quick macro for required C calls via function pointer
macro ccall(fsym::Symbol, rett, argt, args...)
    quote
        local _fp = libfloat_fptr(fsym)
        ccall(_fp, $(esc(rett)), $(esc(argt)), $(map(esc, args)...))
    end
end

macro ccall(fname, rett, argt, args...)
    quote
        local _fp = libfloat_fptr(Symbol($fname))
        ccall(_fp, $(esc(rett)), $(esc(argt)), $(map(esc, args)...))
    end
end


end  # NFloats
