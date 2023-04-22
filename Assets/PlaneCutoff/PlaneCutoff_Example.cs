using UnityEngine;

[ExecuteInEditMode]
public class TestSectionPlane : MonoBehaviour
{
    public bool Enable;
    public GameObject plane;
    public GameObject cube;

    void Update()
    {
        Vector3 normal = -plane.transform.forward;
        Vector3 pos = plane.transform.position;

        cube.GetComponent<MeshRenderer>().sharedMaterial.SetFloat("_Enable", Enable ? 1 : 0);
        cube.GetComponent<MeshRenderer>().sharedMaterial.SetVector("_Direction", normal);
        cube.GetComponent<MeshRenderer>().sharedMaterial.SetVector("_Pos", pos);
    }
}
