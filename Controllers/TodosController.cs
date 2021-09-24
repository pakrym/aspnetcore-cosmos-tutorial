using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using DotNetCoreSqlDb.Models;
using Microsoft.Azure.Cosmos;

namespace DotNetCoreSqlDb.Controllers
{
    public class TodosController : Controller
    {
        private readonly Container _container;

        public TodosController(CosmosClient client)
        {
            _container = client.GetContainer("ToDo", "ToDos");
        }

        // GET: Todos
        public async Task<IActionResult> Index()
        {
            List<Todo> allEntries = new List<Todo>();

            FeedIterator<Todo> iterator = _container.GetItemQueryIterator<Todo>();
            while (iterator.HasMoreResults)
            {
                var page = await iterator.ReadNextAsync();
                allEntries.AddRange(page);
            }

            return View(allEntries);
        }

        // GET: Todos/Details/5
        public async Task<IActionResult> Details(string id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var todo = await _container.ReadItemAsync<Todo>(id, new PartitionKey(id));

            return View(todo.Resource);
        }

        // GET: Todos/Create
        public IActionResult Create()
        {
            return View(new Todo() { Id = Guid.NewGuid().ToString("N")});
        }

        // POST: Todos/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Id,Description,CreatedDate")] Todo todo)
        {
            if (ModelState.IsValid)
            {
                await _container.CreateItemAsync(todo, new PartitionKey(todo.Id));
                return RedirectToAction(nameof(Index));
            }
            return View(todo);
        }

        // GET: Todos/Edit/5
        public async Task<IActionResult> Edit(string id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var todo = await _container.ReadItemAsync<Todo>(id, new PartitionKey(id));

            return View(todo.Resource);
        }

        // POST: Todos/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(string id, [Bind("Id,Description,CreatedDate")] Todo todo)
        {
            if (id != todo.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                await _container.UpsertItemAsync(todo, new PartitionKey(todo.Id));
                return RedirectToAction(nameof(Index));
            }
            return View(todo);
        }

        // GET: Todos/Delete/5
        public async Task<IActionResult> Delete(string id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var todo = await _container.ReadItemAsync<Todo>(id, new PartitionKey(id));

            return View(todo.Resource);
        }

        // POST: Todos/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string id)
        {
            await _container.DeleteItemAsync<Todo>(id, new PartitionKey(id));
            return RedirectToAction(nameof(Index));
        }
    }
}
