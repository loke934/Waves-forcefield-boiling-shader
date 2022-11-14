Shader "Unlit/Interaction"
{
    Properties
    {
        _ColorBottom ("Color Bottom", Color) = (0,0,0,0)
        _ColorTop ("Color Top", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent"
            "Queue" = "Transparent" 
            }

        Pass
        {
            Cull Off
            ZWrite Off
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718
            
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD1;
                float3 normal : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _ColorBottom;
            float4 _ColorTop;

            Interpolators vert (MeshData v)
            {
                Interpolators i;
                i.vertex = UnityObjectToClipPos(v.vertex);
                i.normal = UnityObjectToWorldNormal(v.normals);
                i.uv = v.uv0;
                return i;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float yWaves = cos(i.uv.y * TAU * 4) * 0.01;
                float xWaves = cos((i.uv.x + yWaves - _Time.y * 0.1) * TAU * 8) * 0.5 + 0.5;
                xWaves *= 1- i.uv.y; //fade out towards top
                
                float topBottomRemover = (abs(i.normal.y) < 0.999);
                
                float remove = xWaves * topBottomRemover;
                float4 gradient = lerp(_ColorBottom, _ColorTop, i.uv.y);
                return gradient * remove;
            }
            ENDCG
        }
    }
}
