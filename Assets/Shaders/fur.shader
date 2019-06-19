Shader "pyc/fur"{
Properties {
  _Diffuse ("dif tex ", 2D ) = "white"{}
  _furlength ("ful length",float )= 0 
  _uvscale  ("uv scale ",float ) = 1.0 
  _layer ("layer ",float ) = 0 
  _vGravity ("重力",vector)  =(0,-2.0,0,0)
  _vecLightDir ("方向",Vector) = (0.8,0.8,1.0,1.0) 
  
  

}
SubShader{
 Tags{ "Queue" = "Geometry" "RenderType"="Opaque" }
pass{
    Name  "Ford" 
     // 内部 tag 只是写光照路径 
    Tags{  "LightMode" = "ForwardBase"
    }
    Blend  SrcAlpha  OneMinusSrcAlpha    
    Cull Back 
    ZWrite On 

  
    CGPROGRAM
    #pragma  vertex  vert 
    #pragma fragment frag 
    #include  "UnityCG.cginc"
    
    struct  vertexInput {
      float3 position : POSITION ;
      float3 normal :NORMAL ;
      float4 uv : TEXCOORD0 ;

    };
   struct  vertexOutput {
     float4 HPos  : SV_POSITION ;
     float2 uv0   :TEXCOORD0 ;
     float3 normal :TEXCOORD1 ;

   };
   float _furlength ,_uvscale, _layer ;
   float4 _vGravity ,_vecLightDir ;
   sampler2D _Diffuse ;
   
   vertexOutput  vert (vertexInput v )
   {
      vertexOutput  o = (vertexOutput)0 ;
      float3 P = v.position+(v.normal*_furlength) ;
      float3 normal = UnityObjectToWorldNormal (v.normal) ; 
      float3 _vG=  UnityObjectToWorldDir(_vGravity.xyz ) ;
      float k = pow(_layer ,3) ;
      P =P + _vG*k ;

      o.HPos = UnityObjectToClipPos(P ) ;
      o.normal = normal ;
      return o ; 

   } 

   float4 frag (vertexOutput i ):COLOr 
   {
     float4  Furcolor = tex2D(_Diffuse , i.uv0) ;
     float4 ambient = float4(0.3, 0.3, 0.3, 0.0); 
     ambient = ambient *Furcolor ; 

     float4 toto  = Furcolor + ambient* dot( normalize(_vecLightDir), i.normal) ;
    toto.a = Furcolor.r ;
     return toto ;




   }







    ENDCG
}


}


}