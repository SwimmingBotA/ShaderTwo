// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/CubeTest"
{
    Properties
    {
        _BumpTex("BumpTex",2D)="bump"{}
        _CubeTex("CubeTex",Cube)="_Skybox"{}
        _OcculusionTex ("OcculusionTex", 2D) = "white" {}
        _FresnelPow("FresnelPow",Range(0.0,8.0))=1.0
        _Strength("Strength",Range(0.0,5.0))=1.0
        _MipmapLevel("MipmapLevel",Range(0.0,10.0))= 0.0
        
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
                "RenderType"="Opaque"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase_fullshadows

            #include "UnityCG.cginc"

            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            sampler2D _OcculusionTex;

            samplerCUBE _CubeTex;

            half _FresnelPow;
            half _MipmapLevel;

            fixed _Strength;


            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float2 uv0:TEXCOORD0;     //NormalMap
                float2 uv1:TEXCOORD1;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPositon:TEXCOORD1;
                float3 worldTangent:TEXCOORD2;
                float3 worldBiTangent:TEXCOORD3;
                float2 uv0:TEXCOORD4;
                float2 uv1:TEXCOORD5;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPositon = mul(unity_ObjectToWorld,v.vertex);

                o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                o.worldTangent = normalize( mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.worldBiTangent = normalize(cross(o.worldNormal,o.worldTangent)*v.tangent.w);


                o.uv0 = TRANSFORM_TEX(v.uv0,_BumpTex);
                o.uv1 = v.uv1;

                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPositon));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPositon));

                float3 tangentNormal = UnpackNormal(tex2D(_BumpTex,i.uv0)).rgb;
                float3x3 TBN = float3x3(i.worldTangent,i.worldBiTangent,i.worldNormal);
                float3 worldNormalDir = normalize(mul(tangentNormal,TBN));

                float3 viewNormalDir = mul(UNITY_MATRIX_V,float4(worldNormalDir,0.0)).xyz;
                float3 worldRefViewDir = reflect(-worldViewDir,worldNormalDir);
                
                float fresnel = pow((1-dot(worldNormalDir,worldViewDir)),_FresnelPow);

                float3 diffuse =  max(0,dot(worldNormalDir,worldLightDir));

                float3 environment = texCUBElod(_CubeTex,float4(worldRefViewDir,_MipmapLevel)).rgb;

                float occulusion = tex2D(_OcculusionTex,i.uv1).r;
                

                float3 finalColor = environment * diffuse * fresnel * _Strength * occulusion;

                return float4(finalColor,1.0);
            }

            ENDCG
 
        }
    }
    FallBack "Diffuse"
}
