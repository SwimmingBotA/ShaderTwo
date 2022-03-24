// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/SSS"
{
    Properties
    {
        _SSSTexture ("SSSTexture", 2D) = "white" {}
        _Strength("Strength",Range(0.0,1.0))=0.1
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            


            sampler2D _SSSTexture;
            fixed _Strength;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPosition:TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex).xyz;
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));
                fixed diff = dot(worldNormal,worldLightDir);
                diff = diff*0.5+0.5;
                fixed3 diffuse = _LightColor0.rgb * tex2D(_SSSTexture,fixed2(diff,_Strength));

                return fixed4(diffuse,1.0);
            }
            ENDCG
        }
    }
}
