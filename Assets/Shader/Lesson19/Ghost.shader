Shader "Ariaaaaa/Ghost"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Opacity("Opacity",Range(0.0,1.0))=1.0
        _Head("X:Int Y:Speed Z:High W:EmitInt",Vector)=(1.0,1.0,1.0,0.0)
        _DwonX("X:Int Y:Speed Z:SwingInt",Vector)=(1.0,1.0,1.0,0.0)
        _DwonZ("X:Int Y:Speed Z:SwingInt",Vector)=(1.0,1.0,1.0,0.0)
        _Face("X:RotateRange Y:Speed Z:HeadSpeed",Vector)=(1.0,1.0,1.0,0.0)
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

          half _Opacity;

          half4 _Head;
          half4 _DwonX;
          half4 _DwonZ;
          half4 _Face;

          #define TWO_PI 6.283185

          void Ghost(inout float3 vertex,inout float3 color)
          {
            float headScale = _Head.x * color.g * sin(frac(_Time.y * _Head.y)*TWO_PI);
            vertex.xyz *= 1.0 + headScale;
            vertex.y -= _Head.z * headScale;

            float swingX = _DwonX.x * color.r * sin(frac(_Time.y * _DwonX.y + vertex.y *_DwonX.z )*TWO_PI);
            float swingZ = _DwonZ.x * color.r * sin(frac(_Time.y * _DwonZ.y + vertex.y *_DwonZ.z )*TWO_PI);
            vertex.xz +=float2(swingX,swingZ);

            float radY = radians(_Face.x) * (1-color.r) * sin(frac(_Time.y * _Face.y - color.g * _Face.z )*TWO_PI);
            float sinY;
            float cosY;
            sincos(radY,sinY,cosY);
            vertex.xz = float2
             (
                vertex.x * cosY + vertex.z * sinY,
                vertex.x * -sinY + vertex.z * cosY
             );

             float emit = 1.0 + headScale;
             color = float3(emit,emit,emit);

          }

          struct a2v
          {
              float4 vertex:POSITION;
              float2 uv:TEXCOORD0;
              float3 color:COLOR;
          };

          struct v2f
          {
              float4 pos:SV_POSITION;
              float2 uv:TEXCOORD0;
              float3 color:COLOR;
          };

          v2f vert(a2v v)
          {
            v2f o;
            Ghost(v.vertex.xyz,v.color);
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            o.color = v.color;
            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            float4 mainTex = tex2D(_MainTex,i.uv);

            float3 finalColor = mainTex.rgb * i.color;

            float opacity = mainTex.a * _Opacity;

            return float4(finalColor*opacity,opacity);
          }
          ENDCG
        }
    }
}
