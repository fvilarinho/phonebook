package br.app.vila.phonebook.repository;

import br.app.vila.phonebook.model.Phone;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface PhoneRepository extends MongoRepository<Phone, Long> {
    List<Phone> findByNameContainingIgnoreCase(String name);
    Phone findFirstByOrderByIdDesc();
}