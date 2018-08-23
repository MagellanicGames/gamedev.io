float4x4 World;
float4x4 View;
float4x4 Projection;  

Texture2D SpriteSheet;

SamplerState SpriteSheetSampler
{
	Filter = None;
	AddressU = Wrap;
	AddressV = Wrap;
	Texture = (SpriteSheet);
};

struct VertexShaderInput
{
	float4 Position : POSITION0;
	float4 Normal : NORMAL0;
	float2 TextureUV : TEXCOORD0;

};

struct VertexShaderOutput
{
	float4 Position : POSITION0;
	float2 TextureUV : TEXCOORD0;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
	VertexShaderOutput output;

	float4 worldPosition = mul(input.Position, World);
	float4 viewPosition = mul(worldPosition, View);
	output.Position = mul(viewPosition, Projection);
	output.TextureUV = input.TextureUV;
	return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{

	return tex2D(SpriteSheetSampler, input.TextureUV);
}

technique basic
{
	pass Pass1
	{
		VertexShader = compile vs_2_0 VertexShaderFunction();
		PixelShader = compile ps_2_0 PixelShaderFunction();
	}
}
