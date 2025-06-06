// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

// This shader uses preprocessor macros to adapt to different texture types and layouts.
// Ideally we would use Slang's link time specialization to achieve the same effect,
// but there are some limitations in the current implementation that prevent us from doing so.
// Mainly we cannot use link time specialization to change the resource format of the source texture
// as well as the render target output type.

// This shader expects the following defines to be set externally:
// - SRC_LAYOUT (LAYOUT_TEXTURE2D, LAYOUT_TEXTURE2D_ARRAY)
// - SRC_TYPE (TYPE_FLOAT, TYPE_INT)
// - DST_TYPE (TYPE_FLOAT, TYPE_INT)

#define TYPE_FLOAT 0
#define TYPE_INT 1

#define LAYOUT_TEXTURE2D 0
#define LAYOUT_TEXTURE2D_ARRAY 1


#if SRC_TYPE == TYPE_FLOAT
typedef float4 SrcType;
#elif SRC_TYPE == TYPE_INT
typedef uint4 SrcType;
#else
#error "Invalid SRC_TYPE"
#endif

#if DST_TYPE == TYPE_FLOAT
typedef float4 DstType;
#elif DST_TYPE == TYPE_INT
typedef uint4 DstType;
#else
#error "Invalid DST_TYPE"
#endif

#if SRC_LAYOUT == LAYOUT_TEXTURE2D
typedef Texture2D<SrcType> SrcTexture;
#elif SRC_LAYOUT == LAYOUT_TEXTURE2D_ARRAY
typedef Texture2DArray<SrcType> SrcTexture;
#else
#error "Invalid SRC_LAYOUT"
#endif

extension Texture2D
{
    SrcType sample(SamplerState s, float2 uv)
    {
#if SRC_TYPE == TYPE_FLOAT
        return this.Sample(s, uv);
#elif SRC_TYPE == TYPE_INT
        return asuint(this.Sample(s, uv));
#endif
    }
}

extension Texture2DArray
{
    SrcType sample(SamplerState s, float2 uv)
    {
#if SRC_TYPE == TYPE_FLOAT
        return this.Sample(s, float3(uv, 0));
#elif SRC_TYPE == TYPE_INT
        return asuint(this.Sample(s, float3(uv, 0)));
#endif
    }
}

SrcTexture src;
SamplerState sampler;

struct VSOut {
    float4 pos : SV_Position;
    float2 uv : UV;
};

[shader("vertex")]
VSOut vs_main(uint vid: SV_VertexID)
{
    VSOut vs_out;
    vs_out.uv = float2((vid << 1) & 2, vid & 2);
    vs_out.pos = float4(vs_out.uv * float2(2, -2) + float2(-1, 1), 0, 1);
    return vs_out;
}

[shader("fragment")]
DstType fs_main(VSOut vs_out)
    : SV_Target
{
    float2 uv = vs_out.uv;
    let value = src.sample(sampler, uv);
    return reinterpret<DstType>(value);
}
