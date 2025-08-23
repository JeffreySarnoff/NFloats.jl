const libflint_filepath = FLINT_jll.libflint
if !isfile(libflint_filepath)
    throw(ErrorException("FLINT_jll not found"))
end
    
const libflint_handle = Libdl.dlopen(libflint_filepath)

libfloat_funcptr(sym::Symbol) = dlsym(libflint_handle, sym)
    
macro libflint(function_name)
    return (:($function_name), libflint_handle)
end

macro ccall(fname, rett, argt, args...)
    quote
        local _fp = libflint_funcptr(Symbol($fname))
        ccall(_fp, $(esc(rett)), $(esc(argt)), $(map(esc, args)...))
    end
end
