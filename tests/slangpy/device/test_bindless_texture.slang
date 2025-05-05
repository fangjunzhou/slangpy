
struct TextureInfo
{
    Texture2D<float>.Handle texture;
    SamplerState.Handle sampler;
    float2 uv;
};

StructuredBuffer<TextureInfo> texture_infos;
RWStructuredBuffer<float> results;

[shader("compute")]
[numthreads(1, 1, 1)]
void computeMain(uint3 tid : SV_DispatchThreadID)
{
    uint index = tid.x;
    TextureInfo info = texture_infos[index];
    results[index] = info.texture.SampleLevel(info.sampler, info.uv, 0);
}
