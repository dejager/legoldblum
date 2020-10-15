#include <metal_stdlib>
using namespace metal;

#define grid 26.0

kernel void lifeUhFindsAWay(texture2d<float, access::write> o[[texture(0)]],
                                      texture2d<float, access::read> i[[texture(1)]],
                                      constant float &time [[buffer(0)]],
                                      constant float2 *touchEvent [[buffer(1)]],
                                      constant int &numberOfTouches [[buffer(2)]],
                                      ushort2 gid [[thread_position_in_grid]]) {

  int width = o.get_width();
  int height = o.get_height();
  float2 res = float2(width, height);
  float2 p = float2(gid.xy);
  p /= res.y;

  //blocky pixel coordinates
  float2 middle = floor(p * grid + 0.5) / grid;
  float2 mid = floor(p * grid + 0.5) / (grid + 1);
  ushort2 id = ushort2(mid * res);
  float3 col = i.read(id).rgb;

  //lego stuff
  // top
  float dist = abs(distance(p, middle) * grid * 2.0 - 0.6);
  col *= smoothstep(0.1, 0.05, dist) * dot(float2(0.707), max(float2(-1.0, -1.0), normalize(p - middle))) * 0.5 + 1.0;

  // shadow
  float2 delta = abs(p - middle) * grid * 2.0;
  float sdist = max(delta.x, delta.y);

  col *= 0.8 + smoothstep(0.95, 0.8, sdist) * 0.2;

  float3 ic = i.read(gid).rgb;
  float4 color = float4(ic, 1.0);
  o.write(float4(col, 1.0), gid);
}
