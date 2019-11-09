fun everyNth(L: List<Any>, N: Int ): List<Any>
{
	val list = mutableListOf<Any>()
	if (N > 0)
	{
		var i = N - 1 
		while (i < L.size)
		{
			list.add(L[i])
			i = i + N
		}
	}
	return list
}

fun main(args: Array<String>){
	val list = listOf<String> ("a", "b", "c", "d","e","f")
	val listcheck = listOf<String> ("c", "f")
	val returnedlist = everyNth(list, 3)
	if (returnedlist == listcheck)
		println("Test 1 Passed!")

	val list2 = listOf<Int> (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	val list2check = listOf<Int>(2, 4, 6, 8, 10)
	val returnedlist2 = everyNth(list2, 2)
	if(returnedlist2 == list2check)
		println("Test 2 Passed!")

	val list3 = listOf<Int>(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	val list3check = listOf<Int>(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	val returnedlist3 = everyNth(list3, 1)
	if (returnedlist3 == list3check)
		println("Test 3 Passed!")

	val list4 = listOf<String>("a", "b", "c")
	val list4check = listOf<String>("b")
	val returnedlist4 = everyNth(list4, 2)
	if (returnedlist4 == list4check)
		println("Test 4 Passed!")
}