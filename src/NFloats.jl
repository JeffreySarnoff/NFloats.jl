module NFloats

using Libdl
using FLINT_jll

const libflint_filepath = FLINT_jll.libflint
if !isfile(libflint_filepath)
    throw(ErrorException("FLINT_jll not found"))
end
    
const libflint_handle = Libdl.dlopen(libflint_filepath)

const CPtr = Ptr{Nothing}

# flags 
# NFLOAT_ALLOW_UNDERFLOW does not slow vector processing
# flags NFLOAT_ALLOW_INF slows vector processing
# flags NFLOAT_ALLOW_NAN slows vector processing

const NFLOAT_ALLOW_UNDERFLOW = 0x01
const NFLOAT_ALLOW_INF       = 0x02
const NFLOAT_ALLOW_NAN       = 0x04

const NFLOAT_ALLOW_ALL       = 0x04 | 0x02 | 0x01
const NFLOAT_DISALLOW_NAN    = 0x02 | 0x01
const NFLOAT_DISALLOW_INF    = 0x04 | 0x01


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

# underlying structs
# https://github.com/kalmarek/Arblib.jl/pull/202

const GR_CTX_STRUCT_DATA_BYTES = 6 * sizeof(UInt)
mutable struct nfloat_ctx_struct{P,F}
    data::NTuple{GR_CTX_STRUCT_DATA_BYTES, UInt8}
    which_ring::UInt
    sizeof_elem::Int
    methods::Ptr{Cvoid}
    size_limit::UInt

    function nfloat_ctx_struct{P, F}() where {P, F}
        @assert P isa Int && F isa Int
        ctx = new{P,F}()
        ret = init!(ctx, 64P, F)
        iszero(ret) || throw(DomainError(P, "cannot set precision to this value"))
        return ctx
    end
end

const NFLOAT_HEADER_LIMBS = 2
mutable struct nfloat_struct{P,F}
    head::NTuple{NFLOAT_HEADER_LIMBS,UInt}
    d::NTuple{P,UInt} # FIXME: Should be different for 32 bit systems

    function nfloat_struct{P,F}() where {P,F}
        @assert P isa Int && F isa Int
        res = new{P,F}()
        init!(res, nfloat_ctx_struct{P,F}())
        return res
    end
end

# or

# gr_ctx_struct (public header). We mirror it by value.
const GR_CTX_STRUCT_DATA_BYTES = 6*sizeof(Culong)

struct GRDataBlob
    bytes::NTuple{GR_CTX_STRUCT_DATA_BYTES, UInt8}
end

struct GrCtxStruct
    data::GRDataBlob
    which_ring::Culong
    sizeof_elem::Clong
    methods::Ptr{Cvoid}
    size_limit::Culong
end

mutable struct GrCtx
    ctx::GrCtxStruct
end

@inline _ctxref(g::GrCtx) = Ref(g.ctx)

# nfloat{BITS}_struct: head[2] + d[bits/64] (public header pattern)
# (If your FLINT build changes this, adjust below accordingly.)
const FLINT_BITS = 64

@generated function _nlimbs(::Val{B}) where {B}
    n = Int(B) ÷ FLINT_BITS
    :(Val{$n}())
end
  
macro def_nfloat_struct(bits)
    nb = bits ÷ FLINT_BITS
    T  = Symbol("NFloat", bits, "Struct")
    quote
        struct $T
            head::NTuple{2, Culong}
            d::NTuple{$nb, Culong}
        end
    end
end

end  # NFloats
