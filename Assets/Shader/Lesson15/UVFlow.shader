// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/UVFlow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Voice("Voice",2D)="gray"{}
        _Opacity("Opacity",Range(0.0,1.0))=1.0
        _FlowSpeed("FlowSpeed",Range(-10.0,30.0))=1.0
        _VoiceInt("VoiceInt",Range(0.0,1.0))=0.0
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
          //#pragma multi_compile_fwdbase_fullshadow

          #include "UnityCG.cginc"
          #include "AutoLight.cginc"
          #include "Lighting.cginc"

          sampler2D _MainTex;
          
          sampler2D _Voice;
          float4 _Voice_ST;

          half _VoiceInt;
          half _FlowSpeed;
          half _Opacity;

          struct a2v
          {
              float4 vertex:POSITION;
              float2 uv:TEXCOORD0;
          };

          struct v2f
          {
              float4 pos:SV_POSITION;
              float2 uv0:TEXCOORD0;
              float2 uv1:TEXCOORD1;
          };

          v2f vert(a2v v)
          {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv0 = v.uv;
            o.uv1 = TRANSFORM_TEX(v.uv,_Voice);
            o.uv1.y = o.uv1.y + frac(_Time.x * _FlowSpeed);
            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            float4 mainTex = tex2D(_MainTex,i.uv0);
            float voiceTex = tex2D(_Voice,i.uv1);

            float3 baseColor = mainTex.rgb;

            float noise = lerp(1.0,voiceTex*2.0,_VoiceInt);
            noise = max(0.0,noise);

            float opacity = mainTex.a * _Opacity * noise;

            return float4(baseColor * opacity,opacity);
          }
          ENDCG
        }
    }
}
