const libflint_filepath = FLINT_jll.libflint
if !isfile(libflint_filepath)
    throw(ErrorException("FLINT_jll not found"))
end
    
const libflint_handle = Libdl.dlopen(libflint_filepath)
