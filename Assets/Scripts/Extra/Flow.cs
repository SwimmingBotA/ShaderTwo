using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Flow : MonoBehaviour
{
    new Renderer renderer;
    Material material;
    [SerializeField] Vector2 offsetVelocity;

    private void Awake()
    {
        renderer = GetComponent<Renderer>();
        material = renderer.material;

        if (material == null)
        {
            this.enabled = false;
        }
    }

    private IEnumerator Start()
    {
        Vector2 change = Vector2.zero;
        while (isActiveAndEnabled)
        {
            change += offsetVelocity * Time.deltaTime;
            material.SetTextureOffset("_VoiseTex", change);
            yield return null;
        }
    }
}
