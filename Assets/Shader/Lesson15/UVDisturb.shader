// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/UVDisturb"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Disturb("Voice",2D)="gray"{}
        _Opacity("Opacity",Range(0.0,1.0))=1.0
        _FlowSpeed("FlowSpeed",Range(-10.0,30.0))=1.0
        _VoiceInt("VoiceInt",Range(0.0,1.0))=0.0
        _DisturbInt("DisturbInt",Range(0.0,1.0))=1.0
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
          
          sampler2D _Disturb;
          float4 _Disturb_ST;

          half _VoiceInt;
          half _FlowSpeed;
          half _Opacity;
          half _DisturbInt;

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
            o.uv1 = TRANSFORM_TEX(v.uv,_Disturb);
            o.uv1.y = o.uv1.y + frac(_Time.x * _FlowSpeed);
            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            float3 disturb = tex2D(_Disturb,i.uv1).rgb;
            float2 uvBias = (disturb.rg - 0.5) * _DisturbInt;
            float2 uv0 = i.uv0 + uvBias;

            float4 mainTex = tex2D(_MainTex,uv0);

            float3 baseColor = mainTex.rgb;

            float noise = lerp(1.0,disturb.b*2.0,_VoiceInt);
            noise = max(0.0,noise);

            float opacity = mainTex.a * _Opacity * noise;

            return float4(baseColor * opacity,opacity);
          }
          ENDCG
        }
    }
}
