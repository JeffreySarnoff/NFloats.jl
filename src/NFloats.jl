module NFloats

using Libdl
using FLINT_jll

include("constants.jl")
include("libflint.jl")

# underlying structs
# https://github.com/kalmarek/Arblib.jl/pull/202

mutable struct nfloat_ctx_struct{P, F}
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
mutable struct nfloat_struct{Precision, Flags}
    head::NTuple{NFLOAT_HEADER_LIMBS,UInt}
    d::NTuple{Precision, UInt} # FIXME: Should be different for 32 bit systems

    function nfloat_struct{Precision::Int, Flags::Int}() where {Precision, Flags}
        res = new{Precision, Flags}()
        init!(res, nfloat_ctx_struct{Precision, Flags}())
        return res
    end
end


# or

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

end  # NFloats
