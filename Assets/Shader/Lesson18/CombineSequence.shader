// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/CombineSequence"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Sequence("Sequence",2D) = "white" {}
        _Opacity("Opacity",Range(0.0,1.0))=1.0
        _Vertical("Vertical",float)=0.0
        _Horizontal("Horizontal",float)=0.0
        _Speed("Speed",float)=0.0
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="TransparentCutout"
            "ForceNoShadowCasting"="True"
            "IgnoreProjector"="True"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            Blend One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half _Opacity;

            struct a2v
            {
              float4 vertex:POSITION;
              float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float4 finalColor = tex2D(_MainTex,i.uv);

                half opacity = finalColor.a * _Opacity;

                return float4(finalColor.rgb * opacity,opacity);
            } 
           ENDCG
        }

                Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            
            Blend One One

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _Sequence;
            float4 _Sequence_ST;
            float _Vertical;
            float _Horizontal;
            float _Speed;

            struct a2v
            {
              float4 vertex:POSITION;
              float3 normal:NORMAL;
              float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                v.vertex.xyz += v.normal*0.03;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_Sequence);

                float time = floor(_Time.y * _Speed);
                float row = floor(time/_Vertical);
                float cloum = time - row * _Vertical;

                float stepU = 1.0/_Vertical;
                float stepV = 1.0/_Horizontal;

                float2 initialization = o.uv * float2(stepU,stepV) + float2(0.0,stepV*(_Horizontal-1));

                o.uv = initialization +float2(stepU*cloum,stepV*-row);

                
                
                return o;
            }

            float4 frag(v2f i):SV_Target
            {            
                float4 sequence = tex2D(_Sequence,i.uv);

                float3 finalColor = sequence.rgb;

                float opacity = sequence.a;

                return float4(finalColor * opacity,opacity);
            }
            
            ENDCG
        
        }

    }
}
