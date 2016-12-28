using UnityEngine;
using System.Collections;

public class CubeController : MonoBehaviour {

	public GameObject cube;
	private Vector3 curAngle; // current angle of the gameobject
	private Vector3 tarAngle; // target angle of the gameobject
	public float deltaAngle = 5.0f;

	// Use this for initialization
	void Start () {
		curAngle = new Vector3 (0.0f, 0.0f, 0.0f);
		tarAngle = new Vector3 (0.0f, 0.0f, 0.0f);
	}
	
	// Update is called once per frame
	void Update () {
		UnityEngine.Debug.Log ("Movuino: " + OSCControl.movuino.acc3.x + " " + OSCControl.movuino.acc3.y + " " + OSCControl.movuino.acc3.z + " " +
			OSCControl.movuino.gyr3.x + " " + OSCControl.movuino.gyr3.y + " " + OSCControl.movuino.gyr3.z);

		//tarAngle = new Vector3(-OSCControl.movuino.acc3.y * 180, -OSCControl.movuino.acc3.x * 180, OSCControl.movuino.acc3.x * 180);
		tarAngle = new Vector3(-OSCControl.movuino.acc3.y * 180, 0.0f, OSCControl.movuino.acc3.x * 180);

		if (curAngle.x < tarAngle.x) {
			curAngle.x += deltaAngle;
		}
		if (curAngle.x > tarAngle.x) {
			curAngle.x -= deltaAngle;
		}
		if (curAngle.z < tarAngle.z) {
			curAngle.z += deltaAngle;
		}
		if (curAngle.z > tarAngle.z) {
			curAngle.z -= deltaAngle;
		}

		cube.transform.eulerAngles = curAngle; // rotate cube
		//cube.transform.Translate(cube.transform.forward * Time.deltaTime); // move cube
	}
}