// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/Flow"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BackTex("BackTex",2D)="white"{}
        _VoiseTex("Voise",2D)="white"{}
        _BlendInt("BlendInt",Range(0.0,2.0))=1.0
        _VoiseInt("_VoiseInt",Range(0.0,1.0))=0.1
        _VoiseColor("VoiseColor",Color)=(1.0,1.0,1.0,1.0)
    }
    SubShader
    {

        Pass
        {
            Tags 
            { 
            "RenderType"="Opaque" 
            }
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BackTex;
            sampler2D _VoiseTex;
            float4 _VoiseTex_ST;
            fixed4 _VoiseColor;


            fixed _BlendInt;
            fixed _VoiseInt;

            struct a2v
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                float2 uv1:TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                o.uv1 = TRANSFORM_TEX(v.uv,_VoiseTex);
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float4 mainTex = tex2D(_MainTex,i.uv);
                float3 backTex = tex2D(_BackTex,i.uv);
                float3 voiseTex = tex2D(_VoiseTex,i.uv1);

                float3 blendColor = lerp(backTex,abs(mainTex.a-backTex),_BlendInt);

                float3 selectVoise = step(voiseTex.r,_VoiseInt) * _VoiseColor.rgb;

                float3 blendVoise = lerp(0.0,selectVoise,mainTex.a);

                float3 finalColor = blendColor + blendVoise;

                return float4(finalColor,1.0);
            }


            ENDCG
        }
    }
}
