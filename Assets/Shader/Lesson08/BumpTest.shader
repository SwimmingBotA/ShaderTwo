// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/BumpTest"
{
    Properties
    {
        _BumpTex("BumpTex",2D)="bump"{}
        
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

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPositon:TEXCOORD1;
                float3 worldTangent:TEXCOORD2;
                float3 worldBiTangent:TEXCOORD3;
                float2 uv:TEXCOORD4;

            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                o.worldTangent = normalize( mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz );
                o.worldBiTangent = normalize(cross(o.worldNormal,o.worldTangent)*v.tangent.w);
                o.worldPositon = mul(unity_ObjectToWorld,v.vertex);

                o.uv = TRANSFORM_TEX(v.uv,_BumpTex);

                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPositon));
                float3 tangentNormal = UnpackNormal(tex2D(_BumpTex,i.uv));
                float3x3 TBN = float3x3(i.worldTangent,i.worldBiTangent,i.worldNormal);
                float3 worldNormalDir = mul(tangentNormal,TBN);

                float3 diffuse = _LightColor0.rgb * max(0,dot(worldNormalDir,worldLightDir));

                return float4(diffuse,1.0);
            }

            ENDCG
 
        }
    }
    FallBack "Diffuse"
}
