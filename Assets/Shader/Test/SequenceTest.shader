// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/SequenceTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Horizontal("Horizontal",Range(0.0,10.0))=1.0
        _Vertical("Vertical",Range(0.0,10.0))=1.0
        _Speed("Speed",Range(0.0,1.0))=1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _Vertical;
            half _Horizontal;

            half _Speed;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
           {
                float time = floor(_Time.y * _Speed);
                    
                float row = floor(time/_Vertical);
                float cloum = time - row*_Vertical;


                float2 uv = i.uv+float2(cloum,-row);
                uv.x /=_Vertical;
                uv.y /= _Horizontal;
                
                float3 finalColor = tex2D(_MainTex,uv);

                return float4(finalColor,1.0);

            }
            ENDCG
        }
    }
}
