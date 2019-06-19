/*****************************************************************************/
/*                                                                           */
/* File: fur.fx                                                              */
/* www.xbdev.net                                                             */
/*                                                                           */
/*****************************************************************************/
/*
   Verty basic fur/hair demo showing how to generate realistic looking fur/hair
   using Shaders and DirectX.  
*/
/*****************************************************************************/

float FurLength = 0;
float UVScale   = 1.0f;
float Layer     = 0; // 0 to 1 for the level

//DWORD BCLR = 0xffffffff; // Set background colour of the demo


float3 vGravity = float3(0,-2.0,0); 

float4 vecLightDir = float4(0.8,0.8,1,0); 

texture FurTexture
< 
    string TextureType = "2D";
>;


//------------------------------------
sampler TextureSampler = sampler_state 
{
    texture = <FurTexture>;
    AddressU  = WRAP;        
    AddressV  = WRAP;
    AddressW  = WRAP;
    MIPFILTER = LINEAR;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};



// transformations
float4x4 worldViewProj : WORLDVIEWPROJ;
float4x4 matWorld : WORLD;

//------------------------------------
struct vertexInput {
    float3 position				: POSITION;
    float3 normal				: NORMAL;
    float4 texCoordDiffuse		: TEXCOORD0;
};

struct vertexOutput {
    float4 HPOS		: POSITION;    
    float4 T0	    : TEXCOORD0; // fur alpha
    float4 T1	    : TEXCOORD1; // fur offset / interfur shadowing
    float3 normal   : TEXCOORD2;
};


//------------------------------------
vertexOutput VS_TransformAndTexture(vertexInput IN) 
{
    vertexOutput OUT = (vertexOutput)0;

	//** MAIN LINE ** MAIN LINE ** MAIN LINE ** MAIN LINE ** MAIN LINE **//
	//** MAIN LINE ** MAIN LINE ** MAIN LINE ** MAIN LINE ** MAIN LINE **//
	//This single line is responsible for creating the layers!  This is it! Nothing
	//more nothing less!
	float3 P = IN.position.xyz + (IN.normal * FurLength);
	
	//Modify our normal so it faces the correct direction for lighting if we
	//want any lighting
	float3 normal = normalize(mul(IN.normal, matWorld));
	
	// Couple of lines to give a swaying effect!
	// Additional Gravit/Force Code
	vGravity = mul(vGravity, matWorld);
	float k =  pow(Layer, 3);  // We use the pow function, so that only the tips of the hairs bend
	                           // As layer goes from 0 to 1, so by using pow(..) function is still 
	                           // goes form 0 to 1, but it increases faster! exponentially
	P = P + vGravity*k;
	// End Gravity Force Addit Code


	OUT.T0 = IN.texCoordDiffuse * UVScale; // Pass long texture data
	// UVScale??  Well we scale the fur texture alpha coords so this effects the fur thickness
	// thinness, sort of stretches or shrinks the fur over the object!
	
	OUT.HPOS = mul(float4(P, 1.0f), worldViewProj); // Output Vertice Position Data
    OUT.normal = normal; // Output Normal
    return OUT;
}


//-----------------------------------
float4 PS_Textured( vertexOutput IN): COLOR
{
	float4 FurColour = tex2D( TextureSampler,  IN.T0 ); // Fur Texture - alpha is VERY IMPORTANT!
  	float4 FinalColour = FurColour;
  	
	//--------------------------
	
	//Basic Directional Lighting
	float4 ambient = {0.3, 0.3, 0.3, 0.0};
	ambient = ambient * FinalColour;
	float4 diffuse = FinalColour;
	FinalColour = ambient + diffuse * dot(vecLightDir, IN.normal);
	//End Basic Lighting Code
	
	//--------------------------
	
	FinalColour.a = FurColour.a;
	//return FinalColour;      // fur colour only!
	return FinalColour;       // Use texture colour
	//return float4(0,0,0,0); // Use for totally invisible!  Can't see
}



//-----------------------------------
technique Fur	        
{   
    pass Shell
    {		
		VertexShader = compile vs_1_1 VS_TransformAndTexture();
		PixelShader  = compile ps_1_3 PS_Textured();
		AlphaBlendEnable = true;
		// Final = Dest * DestBlend + Src * SrcBlend, where dest is the pixel on the screen and src is the texel color.
		// blends in D3D are: SRCCOLOR, INVSRCCOLOR, SRCALPHA, INVSRCALPHA, DESTCOLOR, INVDESTCOLOR, DESTALPHA, INVDESTALPHA, ONE, and ZERO.

		// Final = Dest * DestBlend + Src * SrcBlend
		
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		
		CullMode = None;  // Alternatively CCW, CW
    }    
}//End technique Fur

